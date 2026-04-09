#!/bin/bash

# --- Цвета ---
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*"; }
ask()   { echo -ne "${YELLOW}[?]${NC} $*"; }

clear
echo -e "${GREEN}=== Сброс пароля админ-панели wg-easy ===${NC}\n"

# 1. Проверка контейнера
if [ ! "$(docker ps -q -f name=wg-easy)" ]; then
    err "Контейнер wg-easy не запущен. Нечего сбрасывать."
    exit 1
fi

# 2. Вытягиваем текущие настройки
# Получаем внешний хост
WG_HOST=$(docker inspect wg-easy --format='{{range .Config.Env}}{{println .}}{{end}}' | grep WG_HOST | cut -d'=' -f2)
# Получаем порты в чистом виде
OLD_PORTS=$(docker inspect wg-easy --format='{{range $p, $conf := .HostConfig.PortBindings}}{{(index $conf 0).HostPort}}:{{$p}} {{end}}')

# 3. Пароль
ask "Введите НОВЫЙ пароль: "
read -rs new_password
echo -e "\n${GREEN}*** принято ***${NC}"

# 4. Хеш (используем версию :14, чтобы не качать latest)
info "Генерация нового хеша..."
new_hash=$(docker run --rm ghcr.io/wg-easy/wg-easy:14 wgpw "$new_password" | grep 'PASSWORD_HASH=' | cut -d"'" -f2)

if [ -z "$new_hash" ]; then
    err "Ошибка генерации хеша!"
    exit 1
fi

# 5. Перезапуск
info "Обновление контейнера..."

# Формируем порты
PORT_ARGS=""
for p in $OLD_PORTS; do
    PORT_ARGS="$PORT_ARGS -p $p"
done

docker rm -f wg-easy > /dev/null
docker run -d \
  --name=wg-easy \
  -e WG_HOST="$WG_HOST" \
  -e PASSWORD_HASH="$new_hash" \
  $PORT_ARGS \
  --cap-add=NET_ADMIN \
  --sysctl="net.ipv4.ip_forward=1" \
  --restart unless-stopped \
  ghcr.io/wg-easy/wg-easy:14 > /dev/null

echo -e "\n${GREEN}✅ Новый пароль: $new_password${NC}"
# nm
