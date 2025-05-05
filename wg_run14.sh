 # 1
sudo apt update && sudo apt install -y docker.io docker-compose
sudo systemctl enable --now docker

# 2
#!/bin/bash

read -sp "Enter VPN password: " vpn_password
echo


docker run -d \
  --name=wg-easy \
  -e WG_HOST=$(curl -s ifconfig.me) \
  -e PASSWORD="$vpn_password" \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add=NET_ADMIN \
  --sysctl="net.ipv4.ip_forward=1" \
  --restart unless-stopped \
  weejewel/wg-easy

# 3 status
docker ps -a | grep wg-easy

# 4 check 
docker exec wg-easy wg show
