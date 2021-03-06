---
title: "Dhallã§docker-compose.ymlã"
emoji: "ð"
type: "tech" # tech: æè¡è¨äº / idea: ã¢ã¤ãã¢
topics: ["Dhall", "Docker", "Nix" ]
published: false
---

## åºç« 

yamlã¯ã¤ããã[Dhall](https://dhall-lang.org/)ã¸â¦

[ãããã¦åºæ¥ä¸ãã£ããã®ããã¡ãã«ãªãã¾ã](https://github.com/SnO2WMaN/dhall-docker-compose-practice)

## Dhallã¨ã¯

> Dhall is a programmable configuration language that you can think of as: JSON + functions + types + imports

**è¨­å®ï¼è¨­å®ãã¡ã¤ã«ï¼ãæ¸ãããã®è¨èª**ã§ãï¼[çºé³ã¯"dÉl"ã¾ãã¯"dÉËl"ï¼](https://github.com/dhall-lang/dhall-lang#Name)[^pronounce]

[^pronounce]: ã¨ã¯ããä½èã¯[åãã®ãå¥½ãã«](https://github.com/dhall-lang/dhall-lang/issues/144#issuecomment-387459495)ã¨ãã£ãæ¨ãè¨ã£ã¦ãããï¼èªç±ã«å¼ãã§ãè¯ãããããªãã§ããããï¼

éè¦ãªæ§è³ªã¨ãã¦ï¼**é**ãã¥ã¼ãªã³ã°å®å¨ãªè¨èªã¨ãã¦è¨­è¨ããã¦ãã¾ãï¼ã¤ã¾ãï¼ä½ããã®è¨­å®ï¼dhallãã®ãã®ãï¼JSONãYAMLãªã©ã®è¨­å®ãã¡ã¤ã«ï¼ãæ±ºå®çã«åãåºãã¾ãï¼ãã®è¾ºãã®è­°è«ã«ã¯è©³ãããªãã®ã§ï¼è©³ç´°ã¯ãè¿ãã®è¨ç®æ©ç§å­¦ã«è©³ããäººã«è¨ãã¦ãã ããï¼

ãã®ä»ã«ï¼æ¬¡ã®ç¹å¾´ãããã¾ãï¼

- éçã«åãä»ãããå®ç¾©ã§ãã¾ãï¼
- é¢æ°ãæ¸ãã¾ãï¼
- ãã¡ã¤ã«ãããã¯URLã§ã¤ã³ãã¼ããåºæ¥ã¾ãï¼

ä»¥ä¸ã®ç¹å¾´ããï¼è¨­å®ãã¡ã¤ã«ãå®å¨ã«æ¸ãããï¼åå©ç¨ãªå½¢ã§éå¸ããããããã¨ãåºæ¥ã¾ãï¼ï¼å¾è¿°ï¼

## Dhallæ¦è¦³

### åã¨æç¸

Haskellãªã©ã«æ£ãã¦ããã¨å¤åãããªãçè§£ã§ããã¨æãã¾ãï¼ç§ã¯ç¥ããªããæ£ãã¦ããªãã®ã§å¤§å¤è¦å´ãã¾ãããâ¦

`Text`ï¼æå­åï¼ï¼`Natural`ï¼èªç¶æ°ï¼ï¼`Integer`ï¼æ´æ°ï¼ï¼`Double`ï¼å°æ°ï¼ã¨ãã£ãèªç¶ãªãã®ã®ä»ï¼`Type`ï¼åã®åï¼ãããã¾ãï¼

`let num : Natural = 4`

`let Num : Type = Natural`

### ãã¡ã¤ã«/URLã¤ã³ãã¼ã

Dhallã®ãã¡ã¤ã«ã®æ¡å¼µå­ã¯`.dhall`ã§ãï¼

åãã®ãã¡ã¤ã«ã¯ï¼å¿ãä½ããã®å¤ãåºåããå¿è¦ãããã¾ãï¼ï¼ä½ãåºåããªããã¡ã¤ã«ã¯è¨±ãããªãï¼ï¼
ãã®å¶ç´ãããããï¼ãããå¤§éæã«è¨ã£ã¦ãã¾ãã°ï¼ã¤ã³ãã¼ããããã¡ã¤ã«ãªã©ãå¨é¨å±éãã¦ç´åã«1ãã¡ã¤ã«ã¨èãããã¨ãåºæ¥ã¾ãï¼

## è©¦ã

### åæ

ç°¡åã«å¥éããããã«ï¼ä¸è¨ã®ãããªdocker-compose.yml[^docker-compose]ãDhallã«æ¸ãä¸ããã¨ãèããï¼
ãªãï¼`./configs`ä»¥ä¸ã¯ä»åèããªãï¼[ããã«ãã](https://github.com/SnO2WMaN/dhall-docker-compose-practice/tree/50384901d9eea416c129577bf4eb11401f9115da/configs)ï¼

[^docker-compose]: ãã®docker-compose.ymlã®è©³ç´°ã¯ï¼è¦ããã«ï¼Nginxã®ã­ã°ãPromtailã§åãï¼Lokiã«æãã¦ï¼Grafanaã§å¯è¦åããããã¨ããè©¦ã¿ã§ããï¼[åèæç®](https://sublimer.hatenablog.com/entry/2021/09/16/185110)ï¼

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

### Volumeã¨Network

ã¾ã`volumes`ã¨`networks`ã®åãå®ç¾©ããï¼ãï¼æ­£ç´åããªã®ã§[volume.dhall](https://github.com/SnO2WMaN/dhall-docker-compose-practice/blob/main/compose/volume.dhall)ã ãæ²è¼ãã

```dhall
let Map =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/master/Prelude/Map/Type

let Volume
    : Type
    = {}

let Volumes = Map Text (Optional Volume)

in  { Volume = { Type = Volume, default = {=} }, Volumes }
```

## åèæç®

ãã£ã¨å½¹ã«ç«ã¡ã¾ã

- [Built-in types, functions, and operators (docs.dhall-lang.org)](https://docs.dhall-lang.org/references/Built-in-types.html)
- [Dhall ã§ Kubernetes ã® YAML ç®¡çãã¹ãã¼ãã«ãã£ã¦ãã(blog.ryota-ka.me, 2018-08-27)](https://blog.ryota-ka.me/posts/2018/08/27/manage-k8s-yaml-with-dhall)
- [Dhallã«ãããªãããªè¨­å®ãã¡ã¤ã«ä½é¨ (syocyâs diary, 2018-07-14)](https://syocy.hatenablog.com/entry/2018/07/14/195255)
- [sbdchd/dhall-docker-compose](https://github.com/sbdchd/dhall-docker-compose)
  - æ¸ãã¦ãã¨ãã«ããªãåèã«ãã

docker-compose.ymlèªä½ãæ¸ããã¨ãã«åèã«ããè¨äº

- [GrafanaãGrafana LokiãPromtailã§Nginxã®ã¢ã¯ã»ã¹ã­ã°ãå¯è¦åããæå¼·ã®ããã·ã¥ãã¼ããä½ã](https://sublimer.hatenablog.com/entry/2021/09/16/185110)

é¢ä¿ãªããã©ï¼æãåºããã®ã§

- [ãã«ãã¦åããããªã](https://www.nicovideo.jp/watch/sm38239116)
