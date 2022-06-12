---
title: "treefmtで統一的なフォーマッタを実現する"
emoji: "🌟"
type: "tech"
topics: [ "treefmt" ]
published: true
---

## はじめに

[treefmt](https://github.com/numtide/treefmt)というフォーマッタの上に被せるCLIが存在し，これによってあらゆるフォーマッタを統一的に扱うことが出来ます．

つまり

- [Prettier](https://github.com/prettier/prettier)
  - TypeScript, JavaScript, Markdown, JSON, CSS, etc...
- [dprint](https://github.com/dprint/dprint)
  - TypeScript, JavaScript, Markdown, JSON, etc...
- [nixpkgs-fmt](https://github.com/nix-community/nixpkgs-fmt)
  - Nix
- [alejandra](https://github.com/kamadorueda/alejandra)
  - Nix
- [taplo](https://github.com/tamasfe/taplo)
  - Toml
- [fourmolu](https://github.com/fourmolu/fourmolu)
  - Haskell
- [cabal-fmt](https://github.com/phadej/cabal-fmt)
  - Cabal
- [satysfi-formatter](https://github.com/usagrada/satysfi-formatter)
  - SATySFi
- [ocamlformat](https://github.com/ocaml-ppx/ocamlformat)
  - OCaml
- [rustfmt](https://github.com/rust-lang/rustfmt)
  - Rust
- [elm-format](https://github.com/avh4/elm-format)
  - Elm
- [black](https://github.com/psf/black)
  - Python
- [gofumpt](https://github.com/mvdan/gofumpt)
  - Go
- [yamlfix](https://github.com/lyz-code/yamlfix)
	- YAML
- `dhall format`
	- [Dhall](https://github.com/dhall-lang/dhall-lang)
- etc...

これらのフォーマッタが

```bash
$ treefmt
```

というコマンド一発で，指定した全てのファイルに作用させることができます．

## 具体的な方法

treefmtは設定ファイルを`treefmt.toml`とします．

具体的に，[この記事の置き場](https://github.com/SnO2WMaN/zenn-articles)の`treefmt.toml`を見てみましょう（[ここにある](https://github.com/SnO2WMaN/zenn-articles/blob/main/treefmt.toml)）

今，プロジェクトのフォーマッタとして[alejandra](https://github.com/kamadorueda/alejandra)（Nixのフォーマッタ）と[dprint](https://github.com/dprint/dprint)（Rustで実装された高速なWebフロントエンド系フォーマッタ）がインストールされた状況とします．

```toml:treefmt.toml
[formatter.alejandra]
command = "alejandra"
includes = ["*.nix"]

[formatter.dprint]
command = "dprint"
options = ["fmt"]
includes = ["*.json", "*.toml", "*.md"]
```

例えば，上の設定ファイルの`dprint`の場合だと`dprint fmt ./package.json`と渡されます．（`command`と`options`に注意！）

その他上には書いていませんが`excludes = []`で個別に除外するファイルなども指定できます．（もちろんフォーマッタ側で指定しても良い．例えば`.prettierignore`などを使って）

これを置いた状態で，`treefmt`を叩くと…

```shell
$ treefmt
[INFO]: #alejandra: 2 files processed in 4.58ms
[INFO]: #dprint: 7 files processed in 41.84ms

traversed 11 files
matched 9 files to formatters
left with 9 files after cache
of whom 1 files were re-formatted
all of this in 44ms
```

プロジェクト以下の`*.nix`，`*.json`，`*.toml`，`*.md`ファイルに適応されました．
2回目移行は，変更されたファイルのみに適応されるようにtreefmt側がよしなにやってくれます．

注意するべきことは，フォーマッタが _in-place_ な整形に対応していることが前提です．つまり`prettier --write`など，**ファイルパスを受け取ったら整形結果を上書きする**ような動作，または動作オプションが必要です．[^not-inplace-formatter]

[^not-inplace-formatter]: [実は出来ないこともない](https://github.com/numtide/treefmt/wiki#clojure)が，結構ハッキーな方法をする．

**さて　これだと　あまり旨味が　少ないので…**

## Custom Local Formatters

私はVSCodeユーザなので，[Custom Local Formatters](https://marketplace.visualstudio.com/items?itemName=jkillian.custom-local-formatters)を使って，treefmtとうまく統合させます．

https://marketplace.visualstudio.com/items?itemName=jkillian.custom-local-formatters

この拡張機能は，関連付けられたファイル[^file-association-vscode]に対してカスタムなフォーマッタ（標準入力を受け取って，標準出力に整形結果を返すコマンド）を当てられるようになります．

[^file-association-vscode]: `settings.json`で`[json]`, `[javascriptreact]`など書く，アレ．

プロジェクトルートの`.vscode/settings.json`に，下を置く．

```json:.vscode/settings.json
{
	"customLocalFormatters.formatters": [
		{
			"command": "treefmt -q --stdin ${file}",
			"languages": [
				"json",
				"jsonc",
				"md",
				"nix",
				"toml"
			]
		}
	],
	"[toml]": {
		"editor.defaultFormatter": "jkillian.custom-local-formatters"
	},
	"[nix]": {
		"editor.defaultFormatter": "jkillian.custom-local-formatters"
	},
	"[json]": {
		"editor.defaultFormatter": "jkillian.custom-local-formatters"
	},
	"[jsonc]": {
		"editor.defaultFormatter": "jkillian.custom-local-formatters"
	},
	"[md]": {
		"editor.defaultFormatter": "jkillian.custom-local-formatters"
	}
}
```

これによって，関連付けられたファイルに`treefmt`が走ってくれるようになります．

これをする利点は，その言語専用の拡張機能が無くても，**あるいは**，あったとしてもフォーマット機能がなくても，**あるいは**，フォーマッタを自由に選択することが出来ない拡張機能であったとしても，開発者は自由なフォーマッタを当てることが出来ます．やったね！

## おわりに

ロマンなので別にここまでしなくてもいいと思う

### ラフな質問

YAMLのフォーマッタってPrettierとyamlfix以外にありませんか？あったらコメントで投げてみてください．

## 付録.1: 個人的な`treefmt.toml`全部詰め合わせ

こっから削ったりしてます

```toml:treefmt.toml
[formatter.alejandra]
command = "alejandra"
includes = ["*.nix"]

[formatter.dprint]
command = "dprint"
options = ["fmt"]
includes = ["*.json", "*.toml", "*.md"]

[formatter.rust]
command = "rustfmt"
includes = ["*.rs"]

[formatter.dhall]
command = "dhall"
options = ["format"]
includes = ["*.dhall"]

[formatter.fourmolu]
command = "fourmolu"
options = [
  "--ghc-opt",
  "-XImportQualifiedPost",
  "--ghc-opt",
  "-XTypeApplications",
  "--mode",
  "inplace",
  "--check-idempotence",
]
includes = ["*.hs"]

[formatter.cabal-fmt]
command = "cabal-fmt"
options = ["--inplace"]
includes = ["*.cabal"]

[formatter.yamlfix]
command = "yamlfix"
includes = ["*.yml", "*.yaml"]

[formatter.ocamlformat]
command = "ocamlformat"
options = ["--inplace"]
includes = ["*.ml"]

[formatter.satysfi-fmt]
command = "satysfi-fmt"
options = ["--write"]
includes = ["*.saty"]
```

## 付録.2: Nixで頑張る

TODO:
