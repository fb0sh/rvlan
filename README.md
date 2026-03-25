docker run -d \
  --name=wireguard \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE `#optional` \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Aisa/Shanghai \
  -e SERVERURL=bj.3.frp.one `#optional` \
  -e SERVERPORT=21194 `#optional` \
  -e PEERS=3 `#optional` \
  -e PEERDNS="" `#optional` \
  -e INTERNAL_SUBNET=10.13.13.0 `#optional` \
  -e ALLOWEDIPS=10.200.3.0/24 `#optional` \
  -e PERSISTENTKEEPALIVE_PEERS= `#optional` \
  -e LOG_CONFS=true `#optional` \
  -p 1194:51820/udp \
  -v $(pwd)/config:/config \
  -v /lib/modules:/lib/modules \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --restart unless-stopped \
  docker.1ms.run/linuxserver/wireguard:latest


sudo wg-quick up ./peer1.conf
