#!/bin/bash
clear

echo "# Установка wg-easy v14 #"
# ------------------------------------------------------------------
echo -e "\nУстановка Docker & Docker Compose"

# 1 Установка Docker (только если не установлен)
if ! command -v docker &> /dev/null; then
    sudo apt update && sudo apt install -y docker.io docker-compose-plugin
    # sudo apt update && sudo apt install -y docker.io docker-compose
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
    echo "Docker успешно установлен и запущен."
else
    echo "Docker уже установлен."
    docker --version
fi

# 2 Установка wg-easy
echo -e "\nУстановка WG"

# 2.1 Удаление старого контейнера (если есть)
echo "Удаление старого контейнера wg-easy (если существует)"
docker rm -f wg-easy 2>/dev/null || true

# 2.2 Запрос пароля VPN
read -sp "Password: " password
echo

# 2.3 Генерация bcrypt-хэша
echo "Генерация хэша пароля..."
hash=$(docker run --rm -i python:slim sh -c \
  "pip install --quiet --no-cache-dir --root-user-action=ignore bcrypt >/dev/null 2>&1 && \
   python -c 'import bcrypt; print(bcrypt.hashpw(\"$password\".encode(\"utf-8\"), bcrypt.gensalt(rounds=8)).decode(\"utf-8\"))'" || \
   { echo "❌ Ошибка генерации хэша"; exit 1; })

# Скачивание образа (с проверкой ошибок)
# if ! docker pull ghcr.io/wg-easy/wg-easy:latest; then
#    echo "❌ Ошибка: не удалось скачать ghcr.io/wg-easy/wg-easy:latest"
#    exit 1
# fi

# 2.4 Запуск WG
docker run -d \
  --name=wg-easy \
  -e WG_HOST=$(curl -s ifconfig.me || echo "YOUR_EXTERNAL_IP") \
  -e PASSWORD_HASH="$hash" \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add=NET_ADMIN \
  --sysctl="net.ipv4.ip_forward=1" \
  --restart unless-stopped \
  ghcr.io/wg-easy/wg-easy:14

# weejewel/wg-easy
# ghcr.io/wg-easy/wg-easy:14 <
# ghcr.io/wg-easy/wg-easy:latest

# 3 status
docker ps -a | grep wg-easy

# 4 check 
docker exec wg-easy wg show

###########################
echo -e "\n"
echo "   Web-интерфейс http://$(curl -s ifconfig.me):51821"
echo "   Пароль: $password"
echo "   Хэш пароля: $hash"
echo "-"
echo "eof..."
