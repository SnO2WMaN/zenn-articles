---
title: "CargoでビルドするRust製ツールをNixでoverrideする"
emoji: "❄️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [ "Nix" ]
published: false
---

## はじめに

Unstableチャンネルでも更新に追いついていないNixのパッケージを，各々でバージョンを指定して最新版を使いたいという欲求がよくある．

今回，Rustで書かれてCargoでビルドするようなパッケージの際，ハマった（というか何を書けば良いのかわからない）ので書き残しておく．

## 前提

例えば執筆時現在，[Taplo](https://taplo.tamasfe.dev/)というTomlフォーマッタ，そのCLIのnixpkgsの定義は[以下のようになっている](https://github.com/NixOS/nixpkgs/blob/c777cdf5c564015d5f63b09cc93bef4178b19b01/pkgs/development/tools/taplo-cli/default.nix)．

```nix
{ lib, rustPlatform, fetchCrate, stdenv, pkg-config, openssl, Security }:

rustPlatform.buildRustPackage rec {
  pname = "taplo-cli";
  version = "0.5.0";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-+0smR1FDeJMSa/LaRM2M53updt5p8717DEaFItNXCdM=";
  };

  cargoSha256 = "sha256-d7mysGYR72shXwvmDXr0oftSa+RtRoSbP++HBR40Mus=";

  nativeBuildInputs = lib.optional stdenv.isLinux pkg-config;

  buildInputs = lib.optional stdenv.isLinux openssl
    ++ lib.optional stdenv.isDarwin Security;

  meta = with lib; {
    description = "A TOML toolkit written in Rust";
    homepage = "https://taplo.tamasfe.dev";
    license = licenses.mit;
    maintainers = with maintainers; [ figsoda ];
    mainProgram = "taplo";
  };
}
```

見てわかるようにバージョン`0.5.0`ですが，このバージョンにはちょっとしたバグが合ったため，執筆時現在最新版の`0.6.2`を使いたいとします．

### TL;DR

最終的には，適当なoverlayを書くことになる．[^1]

[^1]: 別に普通にパッケージインポート時に`overrideAttrs`を呼んでも良い．筆者のケースだとTOMLに設定を書く関係でこうした．

```nix
{
  overlays = [
    (self: super: {
      taplo-cli = super.taplo-cli.overrideAttrs (old: rec {
        inherit (old) pname;
        version = "0.6.2";
        src = super.fetchCrate {
          inherit pname;
          inherit version;
          sha256 = "sha256-vz3ClC2PI0ti+cItuVdJgP8KLmR2C+uGUzl3DfVuTrY=";
        };
        cargoDeps = old.cargoDeps.overrideAttrs (super.lib.const {
          inherit src;
          name = "${old.pname}-${version}-vendor.tar.gz";
          outputHash = "sha256-m6wsca/muGPs58myQH7ZLPPM+eGP+GL2sC5suu+vWU0=";
        });
      });
    })
  ];
}
```

### 諸注意

ここから下は試行錯誤であって動かないので注意．最終的には[参考文献](https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393)を読んで解決した．

まず筆者はこうした．これは全く違うので注意．[^2][^3]

[^2]: 実際`taplo -V`は`0.5.0`を出力する．
[^3]: というかそもそも，普通のパッケージでこう書いても，違うバージョンが入るということは無いと思う，要検証．

```nix
{
  overlays = [
    (self: super: {
      taplo-cli = super.taplo-cli.overrideAttrs (old: rec {
        version = "0.6.2";
      });
    })
  ];
}
```

drvファイルが`taplo-cli-0.6.2.drv`のようになるので，なぜ…と思ったが，ソースファイルは普通にバージョン`0.5.0`のものを持ってきてビルドしている．

次にこう書いた．（sha256は適当に書くとビルド時に正しいものを教えてくれるので，それを）

```nix
{
  overlays = [
    (self: super: {
      taplo-cli = super.taplo-cli.overrideAttrs (old: rec {
        inherit (old) pname;
        version = "0.6.2";
        src = super.fetchCrate {
          inherit pname;
          inherit version;
          sha256 = "sha256-vz3ClC2PI0ti+cItuVdJgP8KLmR2C+uGUzl3DfVuTrY=";
        };
        cargoSha256 = "sha256-d7mysGYR72shXwvmDXr0oftSa+RtRoSbP++HBR40Mus=";
      });
    })
  ];
}
```

実はこれもダメだった，ダメ押しで`lib.mkForce`とかしたがダメだった．

余談で，これはかなり怪しい理解だが[^4]，`src`以下の`sha256`は`https://crates.io`からダウンロードされるソースコードのハッシュで，`cargoSha256`はCargoでビルドした生成物（`*.tar.gz`）のハッシュと考えている．

[^4]: なぜなら私はRustやCargoを解さないので

その後，参考文献を発見した．
曰く，`pkgs.overrideAttrs`で値を上書きしようとする対象は`stdenv.mkDerivation`に渡される属性であって`rustPlatform.buildRustPackage`のそれではない．
つまり，`rustPlatform.buildRustPackage`に渡される`cargoSha256`を`overrideAttrs`で上書きしようとしても意味がないといった旨が書かれている．

ではどうすればいいのかだが，`rustPlatform.buildRustPackage`は最終的に`cargoDeps`を`stdenv.mkDerivation`に渡すので[^5]，これを上書きすればよいのである．再掲すれば以下．

[^5]: https://github.com/NixOS/nixpkgs/blob/823da4d492b8b4ad46bf812db8421d99ff17a8fc/pkgs/build-support/rust/default.nix#L61-L63

```nix
{
  overlays = [
    (self: super: {
      taplo-cli = super.taplo-cli.overrideAttrs (old: rec { 
        src = super.fetchCrate {
          pname = "taplo-cli";
          version = "0.6.2";
          sha256 = "sha256-vz3ClC2PI0ti+cItuVdJgP8KLmR2C+uGUzl3DfVuTrY=";
        };
        cargoDeps = old.cargoDeps.overrideAttrs (super.lib.const {
          inherit src;
          name = "taplo-cli-0.6.2-vendor.tar.gz";
          outputHash = "sha256-m6wsca/muGPs58myQH7ZLPPM+eGP+GL2sC5suu+vWU0=";
        });
      });
    })
  ];
}
```

あとは各々の属性を継承元の値で再利用したりして整理すれば良い．

## おわりに

Nix　むずすぎる

ちなみにこの記事は，[Dhallでdocker-compose.ymlを書く試み](https://github.com/SnO2WMaN/dhall-docker-compose-practice/blob/main/flake.nix)で環境構築をしていた際に発生した問題を記事にしたものである．
この試みについては，そのうち書きます．

## 参考文献

- https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393
