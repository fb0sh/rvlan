# 🚀 rvlan

基于 `kylemanna/openvpn` 的轻量级 VPN 管理脚本，支持：

- ✅ Docker 一键部署 OpenVPN
- ✅ Split Tunnel（仅访问内网，不影响客户端上网）
- ✅ 批量生成 client
- ✅ 自动替换公网连接地址（frp / 端口转发）
- ✅ 一键 start / stop / remove
- ✅ 适合内网穿透 / CTF / 企业实验环境

---

# 📦 环境要求

- Linux / macOS
- Docker 已安装
- root 或 sudo 权限
- iptables（用于内网访问）

---

# ⚙️ 配置说明

编辑脚本顶部：

```bash
OVPN_IMAGE="docker.1ms.run/kylemanna/openvpn:latest"
OVPN_DATA="$PWD/ovpn-data"

OVPN_IP="0.0.0.0"
OVPN_PORT=1194

PUBLIC_NET_HOST="bj.3.frp.one"
PUBLIC_NET_PORT=21194

VPN_SUBNET="10.8.0.0/24"
INTERNAL_NET="10.200.3.0"
INTERNAL_MASK="255.255.255.0"
