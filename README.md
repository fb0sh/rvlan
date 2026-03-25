docker run -d \
  --name=wireguard \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Shanghai \
  -e SERVERURL=bj.3.frp.one \
  -e SERVERPORT=21194 \
  -e PEERS="fb0sh,fr33tcat" \
  -e PEERDNS="8.8.8.8,114.114.114.114" \
  -e INTERNAL_SUBNET=10.13.13.0 \
  -e ALLOWEDIPS=10.200.3.0/24,10.13.13.0/24 \
  -e PERSISTENTKEEPALIVE_PEERS=25 \
  -e LOG_CONFS=true \
  -p 1194:51820/udp \
  -v $(pwd)/config:/config \
  -v /lib/modules:/lib/modules \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --restart unless-stopped \
  lscr.io/linuxserver/wireguard:latest

# if need?
#/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#echo 1 > /proc/sys/net/ipv4/ip_forward

sudo wg-quick up ./peer1.conf
