#!/bin/bash
clear
echo "wg_run15.sh"
# ------------------------------------------------------------------
echo -e "\n"
echo "Установка Docker & Docker Compose"
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


# ------------------------------------------------------------------
echo -e "\n"
echo "Установка WG"
# Проверка существования контейнера
if docker ps -a --format '{{.Names}}' | grep -q "^wg-easy$"; then
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
  wg-easy/wg-easy
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
