---
title: "Dhallでdocker-compose.ymlを"
emoji: "🌟"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Dhall", "Docker", "Nix" ]
published: false
---

## 序章

yamlはつらい　[Dhall](https://dhall-lang.org/)へ…

[こうして出来上がったものがこちらになります](https://github.com/SnO2WMaN/dhall-docker-compose-practice)

## Dhallとは

> Dhall is a programmable configuration language that you can think of as: JSON + functions + types + imports

**設定（設定ファイル）を書くための言語**です．[発音は"dɔl"または"dɔːl"．](https://github.com/dhall-lang/dhall-lang#Name)[^pronounce]

[^pronounce]: とはいえ作者は[各々のお好きに](https://github.com/dhall-lang/dhall-lang/issues/144#issuecomment-387459495)といった旨を言っているし，自由に呼んでも良いんじゃないでしょうか．

重要な性質として，**非**チューリング完全な言語として設計されています．つまり，何らかの設定（dhallそのものか，JSONやYAMLなどの設定ファイル）を決定的に吐き出します．この辺りの議論には詳しくないので，詳細はお近くの計算機科学に詳しい人に訊いてください．

その他に，次の特徴があります．

- 静的に型を付けたり定義できます．
- 関数が書けます．
- ファイルあるいはURLでインポートが出来ます．

以上の特徴より，設定ファイルを安全に書いたり，再利用な形で配布したりすることが出来ます．（後述）

## Dhall概観

### 型と束縛

Haskellなどに慣れていると多分すんなり理解できると思います，私は知らないし慣れていないので大変苦労しましたが…

`Text`（文字列），`Natural`（自然数），`Integer`（整数），`Double`（小数）といった自然なものの他，`Type`（型の型）があります．

`let num : Natural = 4`

`let Num : Type = Natural`

### ファイル/URLインポート

Dhallのファイルの拡張子は`.dhall`です．

各々のファイルは，必ず何らかの値を出力する必要があります．（何も出力しないファイルは許されない．）
この制約があるため，およそ大雑把に言ってしまえば，インポートしたファイルなどを全部展開して直列に1ファイルと考えることが出来ます．

## 試す

### 前提

簡単に入門するために，下記のようなdocker-compose.yml[^docker-compose]をDhallに書き下すことを考える．
なお，`./configs`以下は今回考えない．[ここにある](https://github.com/SnO2WMaN/dhall-docker-compose-practice/tree/50384901d9eea416c129577bf4eb11401f9115da/configs)．

[^docker-compose]: このdocker-compose.ymlの詳細は，要するに，NginxのログをPromtailで取り，Lokiに投げて，Grafanaで可視化するぞ〜という試みである．[参考文献](https://sublimer.hatenablog.com/entry/2021/09/16/185110)．

```yml
version: '3.9'

volumes:
  nginx_log: {}

networks:
  test: {}

services:
  nginx:
    image: nginx
    ports:
      - published: 8080
        target: 80
    volumes:
      - nginx_log/nginx:/var/log/nginx
      - source: "./configs/nginx/nginx.conf"
        target: /etc/nginx/nginx.conf
        type: bind

  loki:
    command: "-config.file=/etc/loki/config.yaml"
    image: grafana/loki:2.5.0
    volumes:
      - source: "./configs/loki/config.yaml"
        target: /etc/loki/config.yaml
        type: bind

  promtail:
    command: "-config.file=/etc/promtail/config.yaml"
    image: grafana/promtail:2.5.0
    volumes:
      - nginx_log/nginx:/var/log/nginx
      - source: "./configs/promtail/config.yaml"
        target: /etc/promtail/config.yaml
        type: bind

  grafana:
    image: grafana/grafana:latest
    ports:
      - published: 3000
        target: 3000
```

### VolumeとNetwork

まず`volumes`と`networks`の型を定義する．が，正直同じなので[volume.dhall](https://github.com/SnO2WMaN/dhall-docker-compose-practice/blob/main/compose/volume.dhall)だけ掲載する

```dhall
let Map =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/master/Prelude/Map/Type

let Volume
    : Type
    = {}

let Volumes = Map Text (Optional Volume)

in  { Volume = { Type = Volume, default = {=} }, Volumes }
```

## 参考文献

きっと役に立ちます

- [Built-in types, functions, and operators (docs.dhall-lang.org)](https://docs.dhall-lang.org/references/Built-in-types.html)
- [Dhall で Kubernetes の YAML 管理をスマートにやっていく(blog.ryota-ka.me, 2018-08-27)](https://blog.ryota-ka.me/posts/2018/08/27/manage-k8s-yaml-with-dhall)
- [Dhallによるリッチな設定ファイル体験 (syocy’s diary, 2018-07-14)](https://syocy.hatenablog.com/entry/2018/07/14/195255)
- [sbdchd/dhall-docker-compose](https://github.com/sbdchd/dhall-docker-compose)
  - 書いてるときにかなり参考にした

docker-compose.yml自体を書いたときに参考にした記事

- [Grafana、Grafana Loki、PromtailでNginxのアクセスログを可視化する最強のダッシュボードを作る](https://sublimer.hatenablog.com/entry/2021/09/16/185110)

関係ないけど，思い出したので

- [ダルくて動きたくない](https://www.nicovideo.jp/watch/sm38239116)
