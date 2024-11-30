# Podman (Docker) 最小化 image 實驗

我試著測試了一下，一個 Yew 專案編成 Docker image 後，可以有多小。這邊採用了 Fedora 裡就有的 podman，用 docker 的人請自行把 podman 直接替換成 docker 即可。

首先是挑選了一個 Yew 裡面的範例，[Game of Life](https://github.com/yewstack/yew/tree/master/examples/game_of_life)，複製過來後當成一個專案的基底。

## Single Stage Debug Build
再來是做最簡單的 [Dockerfile](./Dockerfile.single)，以 Trunk 來編譯與執行，確認在容器中可以正常啟動。
``` shell
podman build -t yew_game_of_life:single -f Dockerfile.single
```

編出來的大小約是這樣：
```
localhost/yew_game_of_life  single              976a5af3078e  10 hours ago  2.25 GB
```

而執行容器的指令則是

``` shell
podman run -p 8080:8080 yew_game_of_life:single
```

## Multi Stage Debug Build
再來則是試著把編譯與執行分離，做出一個比較小的 image。
``` shell
podman build -t yew_game_of_life:single -f Dockerfile.debug
```

編出來的大小約是這樣：
```
localhost/yew_game_of_life  debug               485724f6fd3b  10 hours ago  1.35 GB
```

而執行容器的指令則是

``` shell
podman run -p 8080:8080 yew_game_of_life:debug
```

## Multi Stage Release Build - Python HTTP server
因為 trunk 必須要用到 `cargo metadata`，而無論是哪個 image，只要裝上 cargo 都會飛升到 500 MB 以上的大小，所以我把目光朝向了編完就丟上一個最簡單的 HTTP server 執行的方向。我用了一個 Python 的 Docker image，在不需配置的情況下利用 Alpine 這個用 MUSL C library 的基礎上縮到了最小。
``` shell
podman build -t yew_game_of_life:single -f Dockerfile.pyhttp
```

編出來的大小約是這樣：
```
localhost/yew_game_of_life  pyhttp              3d98e1474819  10 hours ago  52.9 MB
```

而執行容器的指令則是

``` shell
podman run -p 8080:8080 yew_game_of_life:pyhttp
```

## Multi Stage Release Build - NGINX
但上面的還是有著 50 MB 以上的大小，作為最小化來說還是不夠。所以改用了需要設定檔的 NGINX，縮減後的基礎 image 大小只有 18.1 MB，十分吸引人。
``` shell
podman build -t yew_game_of_life:single -f Dockerfile.release
```

編出來的大小約是這樣：
```
localhost/yew_game_of_life  release             ce4891b33fb7  10 hours ago  18.3 MB
```

而執行容器的指令則是

``` shell
podman run -p 8080:8080 yew_game_of_life:release
```
