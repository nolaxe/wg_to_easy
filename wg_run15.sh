#!/bin/bash
clear

# ------------------------------------------------------------------
echo "15"
echo "Установка Docker & Docker Compose"
echo -e "\n"

# Проверяем Docker
if ! command -v docker &> /dev/null; then
    echo "Docker не установлен. Начинаем установку..."
    sudo apt update && sudo apt install -y docker.io docker-compose-plugin
    sudo systemctl enable --now docker
    echo "Docker успешно установлен и запущен."
else
    echo "Docker уже установлен."
    docker --version
fi
# Проверяем Docker Compose V2 (используется как 'docker compose', без дефиса)
if ! command -v docker compose &> /dev/null; then
    echo "Docker Compose V2 не установлен. Устанавливаем..."
    sudo apt install -y docker-compose-plugin
else
    echo "Docker Compose V2 уже установлен."
    docker compose version
fi

# or
# sudo apt update && sudo apt install -y docker.io docker-compose
# sudo systemctl enable --now docker

# ------------------------------------------------------------------
echo "Установка WG"
echo -e "\n"

if docker ps -a --format '{{.Names}}' | grep -q "^wg-easy$"; then
        echo "Контейнер wg-easy уже существует:"
        echo -e "\nКонтейнер wg-easy уже существует:"
        docker ps -a | grep wg-easy
        
        read -p "Хотите остановить и удалить существующий контейнер? [y/N] " yn
        case $yn in
            [Yy]* )
                echo "Останавливаю и удаляю контейнер..."
                docker stop wg-easy >/dev/null 2>&1
                docker rm wg-easy >/dev/null 2>&1
                return 0
                ;;
            * )
                echo "Отмена установки, выход."
                exit 1
                ;;
        esac
    fi

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
# ------------------------------------------------------------------

# 3 status
docker ps -a | grep wg-easy
# 4 check 
docker exec wg-easy wg show

###########################
echo -e "\n"
echo -e "✅ Контейнер wg-easy успешно запущен"
echo "   Web-интерфейс: http://$(curl -s ifconfig.me):51821"
echo "   Пароль: $password"
echo "-"
echo "e o f . . ."

###########################
sleep 10
read -p "Заменить файл app.js? (y/n) " choice
if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo "Загрузка нового app.js..."
    if curl -sSL https://raw.githubusercontent.com/nolaxe/wg_to_easy/main/app_no_upd.js -o app.js; then
        echo "Копирование файла в контейнер..."
        docker cp app.js wg-easy:/app/www/js/app.js
        rm -f app.js
        echo "✅ Файл app.js успешно обновлен!"
    else
        echo "❌ Ошибка при загрузке файла!"
        exit 1
    fi
else
    echo "ℹ️ Отмена. Файл не заменен."
    exit 0
fi
