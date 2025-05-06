#!/bin/bash
clear
echo "wg_run_fast.sh"
docker run -d \
  --name=wg-easy \
  -e WG_HOST=$(curl -s ifconfig.me) \
  -e PASSWORD=$(curl -s ifconfig.me) \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add=NET_ADMIN \
  --sysctl="net.ipv4.ip_forward=1" \
  --restart unless-stopped \
  weejewel/wg-easy
echo "   http://$(curl -s ifconfig.me):51821"
# echo "   Пароль: $password"
curl -sSL https://raw.githubusercontent.com/nolaxe/wg_to_easy/main/addons/app_new.js -o app.js
curl -sSL https://raw.githubusercontent.com/nolaxe/wg_to_easy/main/addons/bender.png -o logo.png
docker cp app.js wg-easy:/app/www/js/app.js
docker cp logo.png wg-easy:/app/www/img/logo.png
rm -f app.js logo.png
echo -e "\n✅ Готово!"
echo -e "\n"
