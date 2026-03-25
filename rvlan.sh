#!/bin/bash
set -e

########################
# 基础配置
########################
# docker.1ms.run/kylemanna/openvpn:latest
OVPN_IMAGE="kylemanna/openvpn:latest"
OVPN_DATA="$PWD/ovpn-data"

OVPN_IP="0.0.0.0"
OVPN_PORT=1194

PUBLIC_NET_HOST="bj.3.frp.one"
PUBLIC_NET_PORT=21194

VPN_SUBNET="10.8.0.0/24"
INTERNAL_NET="10.200.3.0"
INTERNAL_MASK="255.255.255.0"

########################
log() { echo "[INFO] $1"; }

########################
check_container() {
  docker ps -a --format '{{.Names}}' | grep -q openvpn
}

check_image() {
    if docker images -q "$OVPN_IMAGE" > /dev/null 2>&1; then
        log "Found local image: $OVPN_IMAGE"
    else
        log "Error: Image $OVPN_IMAGE not found!"
	docker pull "$OVPVN_IMAGE"
        exit 1
    fi
}

########################
# INIT
########################
init_vpn() {
  log "Init OpenVPN (split tunnel ONLY)..."

  check_image

  rm -rf "$OVPN_DATA"
  mkdir -p "$OVPN_DATA"

  sysctl -w net.ipv4.ip_forward=1 >/dev/null
  grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf || \
    echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf >/dev/null

  docker run --rm -v "$OVPN_DATA:/etc/openvpn" \
    -e EASYRSA_BATCH=1 \
    -e EASYRSA_REQ_CN="FloatCTF" \
    "$OVPN_IMAGE" \
    bash -c "
      ovpn_genconfig -u udp://${OVPN_IP}:${OVPN_PORT} -s ${VPN_SUBNET}
      ovpn_initpki nopass
    "

  CONF="$OVPN_DATA/openvpn.conf"

  ########################
  # 🔥 核心：彻底关闭 full tunnel
  ########################

  # 删除可能存在的 full tunnel
  sed -i '/redirect-gateway/d' "$CONF" || true

  # 删除 DNS push（防止污染客户端）
  sed -i '/dhcp-option DNS/d' "$CONF" || true


  # 只推内网路由
  echo "route ${INTERNAL_NET} ${INTERNAL_MASK}" >> "$CONF"

  log "Init done (split tunnel enforced)"
}

########################
# START
########################
start_vpn() {
  log "Starting OpenVPN..."

  if check_container; then
    docker rm -f openvpn >/dev/null 2>&1 || true
  fi

  docker run -d \
    --name openvpn \
    --cap-add=NET_ADMIN \
    --restart unless-stopped \
    -p ${OVPN_PORT}:1194/udp \
    -v "$OVPN_DATA:/etc/openvpn" \
    "$OVPN_IMAGE"

  sleep 2

  docker ps | grep openvpn && log "OpenVPN running"
}

########################
# STOP
########################
stop_vpn() {
  log "Stopping OpenVPN..."
  docker stop openvpn || true
}

########################
# REMOVE
########################
remove_vpn() {
  log "Removing OpenVPN..."
  docker rm -f openvpn || true
  rm -rf "$OVPN_DATA"
}

########################
# ADD CLIENT
########################
add_client() {
  CLIENT="$1"
  [ -z "$CLIENT" ] && echo "Usage: $0 add client_name" && exit 1

  log "Adding client: $CLIENT"

  docker run --rm -v "$OVPN_DATA:/etc/openvpn" \
    "$OVPN_IMAGE" \
    easyrsa build-client-full "$CLIENT" nopass

  docker run --rm -v "$OVPN_DATA:/etc/openvpn" \
    "$OVPN_IMAGE" \
    ovpn_getclient "$CLIENT" > "${CLIENT}.ovpn"

  # 🔥 强制客户端 split tunnel
  sed -i '/redirect-gateway/d' ${CLIENT}.ovpn
  sed -i "s/^remote .*/remote ${PUBLIC_NET_HOST} ${PUBLIC_NET_PORT}/" "${CLIENT}.ovpn"

  log "Created ${CLIENT}.ovpn"
}

########################
# BATCH CLIENT
########################
gen_clients() {
  COUNT=$1
  for i in $(seq 1 $COUNT); do
    add_client "client$i"
  done
}

########################
# STATUS
########################
status_vpn() {
  docker ps | grep openvpn || echo "OpenVPN not running"
}

########################
# MAIN CLI
########################
case "$1" in
  init)
    init_vpn
    ;;
  start)
    start_vpn
    ;;
  stop)
    stop_vpn
    ;;
  remove)
    remove_vpn
    ;;
  add)
    add_client "$2"
    ;;
  gen)
    gen_clients "$2"
    ;;
  status)
    status_vpn
    ;;
  *)
    echo "Usage:"
    echo "  $0 init"
    echo "  $0 start"
    echo "  $0 stop"
    echo "  $0 remove"
    echo "  $0 add client1"
    echo "  $0 gen 10"
    echo "  $0 status"
    ;;
esac
