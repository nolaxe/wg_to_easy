#!/bin/bash
clear
echo "wg_run_e.sh"


# ------------------------------------------------------------------
# Основная часть
# Настройка WG
read -sp "Введите версию: " ver
echo
read -sp "Введите пароль для веб интерфейса: " password
echo
docker run -d \
  --name=wg-easy \
  -e WG_HOST=$(curl -s ifconfig.me) \
  -e PASSWORD="$password" \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add=NET_ADMIN \
  --sysctl="net.ipv4.ip_forward=1" \
  --restart unless-stopped \
  wg-easy/wg-easy:"$ver"
  # ghcr.io/wg-easy/wg-easy
# ------------------------------------------------------------------

# 3 status
docker ps -a | grep wg-easy
# 4 check 
# docker exec wg-easy wg show

# ------------------------------------------------------------------
echo -e "\n"
echo -e "✅ Контейнер wg-easy успешно запущен"
echo "   Web-интерфейс: http://$(curl -s ifconfig.me):51821"
echo "   Пароль: $password"
echo "-"
echo "eof . . ."

###########################
sleep 1
read -p "Убрать плашку веб интерфейса -Доступно обновление- (docker cp app.js wg-easy:/app/www/js/app.js) ? (y/n) " choice
if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    # Загрузка файлов
    echo "Загружаю файлы..."    
    curl -sSL https://raw.githubusercontent.com/nolaxe/wg_to_easy/main/app_no_upd.js -o app.js
    curl -sSL https://raw.githubusercontent.com/nolaxe/wg_to_easy/main/bender.png -o logo.png
    
    echo "Копирую в контейнер..."
    docker cp app.js wg-easy:/app/www/js/app.js
    docker cp logo.png wg-easy:/app/www/img/logo.png
    
    rm -f app.js logo.png
    
    echo "✅ Готово!"
else
    echo "ℹ️ Отмена."
    exit 0
fi
