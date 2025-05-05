#!/bin/bash

clear

echo "Установка Docker & wg-easy ..."

# 0 Обновление пакетов (делаем ДО проверки Docker)
sudo apt update

# 1 Установка Docker (только если не установлен)
if ! command -v docker &>/dev/null; then
    sudo apt install -y docker.io docker-compose
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
    echo "⚠️ Перезапустите сессию (или выполните 'newgrp docker') и запустите скрипт снова."
    exit 1
fi

# 2 Установка wg-easy

# Запрос пароля VPN
# Генерация bcrypt-хэша (требуется установленный node.js или docker)
read -sp "Password: " password
echo

# 3. Генерация bcrypt-хэша
echo "Генерация хэша пароля..."
hash=$(docker run --rm -i python:slim sh -c \
  "pip install --quiet --no-cache-dir --root-user-action=ignore bcrypt >/dev/null 2>&1 && \
   python -c 'import bcrypt; print(bcrypt.hashpw(\"$password\".encode(\"utf-8\"), bcrypt.gensalt(rounds=8)).decode(\"utf-8\"))'" || \
   { echo "❌ Ошибка генерации хэша"; exit 1; })

# Удаление старого контейнера (если есть)
docker rm -f wg-easy 2>/dev/null || true

# Скачивание образа (с проверкой ошибок)
#  docker pull weejewel/wg-easy:latest >/dev/null 2>&1 || true && \
#  docker pull ghcr.io/wg-easy/wg-easy:latest >/dev/null 2>&1 || true && \
if ! docker pull ghcr.io/wg-easy/wg-easy:latest; then
    echo "❌ Ошибка: не удалось скачать ghcr.io/wg-easy/wg-easy:latest"
    exit 1
fi

# Запуск контейнера
docker run -d \
  --name=wg-easy \
  -e WG_HOST=$(curl -s ifconfig.me || echo "YOUR_EXTERNAL_IP") \
  -e PASSWORD_HASH="$hash" \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add=NET_ADMIN \
  --sysctl="net.ipv4.ip_forward=1" \
  --restart unless-stopped \
  ghcr.io/wg-easy/wg-easy   # launch

# weejewel/wg-easy
# ghcr.io/wg-easy/wg-easy:latest


# 3 status
docker ps -a | grep wg-easy

# 4 check 
docker exec wg-easy wg show

###########################
echo -e "\n"
echo -e "✅ Контейнер wg-easy успешно запущен!"
echo "   Web-интерфейс http://$(curl -s ifconfig.me):51821"
echo "   Пароль: $password"
echo "   Хэш пароля: $hash"
echo "-"
echo "eof..."
