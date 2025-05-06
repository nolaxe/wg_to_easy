#!/bin/bash
clear
echo " Установка wg-easy v12 "
# ------------------------------------------------------------------
echo -e "\n"
echo "Установка Docker & Docker Compose"

# Установка Docker (только если не установлен)
if ! command -v docker &> /dev/null; then
    echo "Docker не установлен. Начинаем установку..."
    sudo apt update && sudo apt install -y docker.io docker-compose-plugin
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
    echo "Docker успешно установлен и запущен."
else
    echo "Docker уже установлен."
    docker --version
fi

# or
# sudo apt update && sudo apt install -y docker.io docker-compose
# sudo systemctl enable --now docker
# ------------------------------------------------------------------

# ------------------------------------------------------------------
echo -e "\nУстановка WG"
# Проверка существования контейнера

# docker ps -a --filter "name=^/wg-easy$" --quiet
# Возвращает: ID контейнера (если контейнер существует) или Пустую строку (если контейнера нет)
# [ -n "строка" ]
# Проверяет, что строка не пустая: Возвращает true (0), если контейнер найден или Возвращает false (1)
if [ -n "$(docker ps -a --filter "name=^/wg-easy$" --quiet)" ]; then 
    echo -e "\nКонтейнер wg-easy существует:"
    docker ps -a --filter "name=^/wg-easy$" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    read -rp "Удалить? [y/N] " yn
    [[ "${yn,,}" =~ ^y ]] && docker rm -f wg-easy &>/dev/null
fi
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# Основная часть
# Настройка WG
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
  weejewel/wg-easy
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
