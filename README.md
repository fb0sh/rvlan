# 🚀 rvlan

基于 kylemanna/openvpn 的轻量级 VPN 管理脚本

## 功能
- Docker OpenVPN 一键部署
- Split Tunnel（仅访问内网）
- 批量生成 client
- 公网域名自动替换
- start / stop / remove 管理

## 使用
```bash
./vpn.sh init
./vpn.sh start
./vpn.sh add client1
./vpn.sh gen 10
```

## 网络模式
- 内网: 10.200.3.0/24
- VPN: 10.8.0.0/24
- 不影响公网访问（无 redirect-gateway）

## 公网访问
remote bj.3.frp.one 21194

