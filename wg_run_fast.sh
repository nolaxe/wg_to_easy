#!/bin/bash
clear
echo "wg_run_fast.sh"

# 1. Определяем IP и Пароль
IP=$(curl -s ifconfig.me)
RAW_PASS=$IP

# 2. Генерируем хеш
hash=$(docker run --rm ghcr.io/wg-easy/wg-easy:latest wgpw "$RAW_PASS" | grep 'PASSWORD_HASH=' | cut -d"'" -f2)

# 3. Удаляем старый контейнер
docker rm -f wg-easy > /dev/null 2>&1

# 4. Запуск
docker run -d \
  --name=wg-easy \
  -e WG_HOST="$IP" \
  -e PASSWORD_HASH="$hash" \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add=NET_ADMIN \
  --sysctl="net.ipv4.ip_forward=1" \
  --restart unless-stopped \
  ghcr.io/wg-easy/wg-easy:14
  #weejewel/wg-easy

# curl -sSL https://raw.githubusercontent.com/nolaxe/wg_to_easy/main/addons/app_new.js -o app.js
curl -sSL https://raw.githubusercontent.com/nolaxe/wg_to_easy/main/addons/bender.png -o logo.png
# docker cp app.js wg-easy:/app/www/js/app.js > /dev/null 2>&1
docker cp logo.png wg-easy:/app/www/img/logo.png > /dev/null 2>&1
#rm -f app.js logo.png
# -----------------------------------------------------

echo -e "\n\033[1;34m----------------------------------------------------------\033[0m"
echo "   URL: http://$IP:51821"
echo -e "\033[1;34m----------------------------------------------------------\033[0m"

echo -e "\n✅ Готово!"
# nm
