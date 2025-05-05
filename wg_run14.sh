#!/bin/bash
clear

# ------------------------------------------------------------------
echo "Установка Docker & Docker Compose"
echo -e "\n"

# Проверяем, установлен ли docker
if ! command -v docker &> /dev/null; then
    echo "Docker не установлен. Начинаем установку..."
    sudo apt update && sudo apt install -y docker.io docker-compose
    sudo systemctl enable --now docker
    echo "Docker успешно установлен и запущен."
else
    echo "Docker уже установлен."
    docker --version
fi
# Проверяем, установлен ли docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose не установлен. Устанавливаем..."
    sudo apt install -y docker-compose
else
    echo "Docker Compose уже установлен."
    docker-compose --version
fi

# or
# sudo apt update && sudo apt install -y docker.io docker-compose
# sudo systemctl enable --now docker

# ------------------------------------------------------------------
echo "Установка WG"
echo -e "\n"

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
echo "   Web-интерфейс http://$(curl -s ifconfig.me):51821"
echo "   Пароль: $password"
echo "-"
echo "eof..."
