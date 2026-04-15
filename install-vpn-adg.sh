#!/bin/bash
# VC !!!

# Твои переменные
IP=$(curl -4 -s --max-time 5 ifconfig.me || echo "ERROR: cannot get IP address")
PROJECT_DIR="$HOME/vpn-blocker"
RAW_PASS="Admin$(date +%s | cut -c7-10)"

echo "--- 1. Генерируем хеш (твой метод) ---"
hash=$(docker run --rm ghcr.io/wg-easy/wg-easy:latest wgpw "$RAW_PASS" | grep 'PASSWORD_HASH=' | cut -d"'" -f2)

if [ -z "$hash" ]; then
    echo "Ошибка: хеш не сгенерировался. Проверь команду генерации."
    exit 1
fi

echo "--- 2. Освобождаем порт 53 (DNS) ---"
sudo systemctl stop systemd-resolved 2>/dev/null
sudo systemctl disable systemd-resolved 2>/dev/null
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf > /dev/null

echo "--- 3. Подготовка папок ---"
mkdir -p $PROJECT_DIR/adguard/{work,conf}
mkdir -p $PROJECT_DIR/wireguard
chmod -R 777 $PROJECT_DIR
cd $PROJECT_DIR

echo "--- 4. Создание docker-compose.yml ---"
cat <<EOF > docker-compose.yml
services:
  adguardhome:
    image: adguard/adguardhome
    container_name: adguardhome
    restart: unless-stopped
    volumes:
      - ./adguard/work:/opt/adguardhome/work
      - ./adguard/conf:/opt/adguardhome/conf
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "3000:3000/tcp"
      - "8080:80/tcp"
    networks:
      vpn_net:
        ipv4_address: 172.20.0.100

  wg-easy:
    image: ghcr.io/wg-easy/wg-easy:latest
    container_name: wg-easy
    restart: unless-stopped
    depends_on:
      - adguardhome
    environment:
      - WG_HOST=$IP
      - PASSWORD_HASH=$hash
      - WG_DEFAULT_DNS=172.20.0.100
      - WG_ENABLE_IPV6=false
    volumes:
      - ./wireguard:/etc/wireguard
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv4.ip_forward=1
    networks:
      vpn_net:
        ipv4_address: 172.20.0.101

networks:
  vpn_net:
    ipam:
      config:
        - subnet: 172.20.0.0/24
EOF

echo "--- 5. Запуск ---"
docker compose down --remove-orphans
docker compose up -d

echo "------------------------------------------------"
echo "WireGuard Panel: http://$IP:51821"
echo "Текстовый пароль: $RAW_PASS"
echo "AdGuard Setup:  http://$IP:3000"
echo "------------------------------------------------"
