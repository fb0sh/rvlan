```bash
#!/bin/bash
PUBLIC_SERVER_HOST="bj.3.frp.one" # 穿透后的 地址
PUBLIC_SERVER_PORT="21194" # 穿透后的 端口 服务端口为 51820
PEERS="fb0sh,fr33tcat" # 生成列表，如果是数字 则是 生成几个
INTERNAL_SUBNET="10.13.13.0" # VPN 的 虚拟网段
ALLOWEDIPS="10.200.3.0/24,10.13.13.0/24" # 允许访问的IP段 可以加上INTERNAL_SUBNET
docker run -d \
  --name=wireguard \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Shanghai \
  -e SERVERURL=$PUBLIC_SERVER_HOST \
  -e SERVERPORT=$PUBLIC_SERVER_PORT \
  -e PEERS=$PEERS \
  -e PEERDNS="8.8.8.8,114.114.114.114"\
  -e INTERNAL_SUBNET=$INTERNAL_SUBNET \
  -e ALLOWEDIPS=$ALLOWEDIPS \
  -e PERSISTENTKEEPALIVE_PEERS=25 \
  -e LOG_CONFS=true \
  -p 51820:51820/udp \
  -v $(pwd)/config:/config \
  -v /lib/modules:/lib/modules \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --restart unless-stopped \
  lscr.io/linuxserver/wireguard:latest
```


sudo wg-quick up ./peer1.conf
