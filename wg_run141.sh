#!/bin/bash

# --- Настройки и Цвета ---
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC} $*"; }; warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; } 
err()   { echo -e "${RED}[ERROR]${NC} $*"; }; ask()   { echo -ne "${YELLOW}[?]${NC} $*"; }

# 1. Функция вывода статуса
get_status() {
    echo -e "\e[1;34m----------------------------------------------------------\e[0m"
    echo -e "\e[1;32m🐳 DOCKER DASHBOARD & STATUS\e[0m"
    echo -e "\e[1;34m----------------------------------------------------------\e[0m"

    echo -e "\n\e[1;33m[ Статус WireGuard ]\e[0m"
    if [ "$(docker ps -aq -f name=wg-easy)" ]; then
        docker ps -a --filter "name=wg-easy" --format "table {{.Names}}\t{{.Status}}\t{{.ID}}\t{{.Image}}"
    else
        echo "Контейнер wg-easy не найден."
    fi

    echo -e "\n\e[1;33m[ Образы в системе ]\e[0m"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"

    if [ ! -z "$password" ]; then
        echo -e "\n\e[1;33m[ Доступ к панели ]\e[0m"
        echo -e "   URL:      ${GREEN}http://$(curl -s ifconfig.me || echo "IP_NOT_FOUND"):${PORT_WEB:-51821}${NC}"
        echo -e "   Пароль:   ${YELLOW}$password${NC}"
    fi
    echo -e "\e[1;34m----------------------------------------------------------\e[0m"
}

# --- НАЧАЛО ВЫПОЛНЕНИЯ ---
clear
get_status

# 2. Зависимости (Твоя новая логика)
if [ ! -f ".dependencies_done" ]; then
    echo
    ask "Установить Docker и плагины? [ENTER - OK / Любая клавиша - отмена]: "
    IFS= read -n 1 -s REPLY; echo ""
    if [[ -z "$REPLY" ]]; then
        info "Установка зависимостей..."
        if ! command -v docker &> /dev/null; then
            curl -fsSL https://get.docker.com | sh
            sudo systemctl enable --now docker
        fi
        sudo apt-get update && sudo apt-get install -y docker-compose-plugin
        touch .dependencies_done
    else
        warn "Установка зависимостей пропущена (нажато: '$REPLY')"
    fi
fi

# 3. Очистка старого контейнера
if [ "$(docker ps -aq -f name=wg-easy)" ]; then
    echo
    ask "Удалить существующий wg-easy? [ENTER - удалить]: "
    IFS= read -n 1 -s REPLY; echo ""
    if [[ -z "$REPLY" ]]; then
        info "Удаление старого контейнера..."
        docker rm -f wg-easy > /dev/null 2>&1
    else
        err "Очистка отменена. Установка прервана."
        exit 1
    fi
fi

# 4. Настройка портов (здесь оставляем обычный read, чтобы можно было вводить цифры)
echo
PORT_VPN_DEF="51820"
ask "Порт VPN (UDP) [Enter - $PORT_VPN_DEF]: "; read -r input_port_vpn
PORT_VPN=${input_port_vpn:-$PORT_VPN_DEF}

PORT_WEB_DEF="51821"
ask "Порт WEB (TCP) [Enter - $PORT_WEB_DEF]: "; read -r input_port_web
PORT_WEB=${input_port_web:-$PORT_WEB_DEF}

# 5. Пароль
echo
ask "Придумайте пароль для админки: "
read -rs password
echo -e "${GREEN}*** принято ***${NC}"

# 6. Установка
info "Генерация хеша..."
hash=$(docker run --rm ghcr.io/wg-easy/wg-easy wgpw "$password" | grep 'PASSWORD_HASH=' | cut -d"'" -f2)

if [ -z "$hash" ]; then
    err "Ошибка генерации хэша!"
    exit 1
fi

info "Запуск контейнера..."
docker run -d \
  --name=wg-easy \
  -e WG_HOST=$(curl -s ifconfig.me || echo "YOUR_EXTERNAL_IP") \
  -e PASSWORD_HASH="$hash" \
  -p ${PORT_VPN}:${PORT_VPN}/udp \
  -p ${PORT_WEB}:${PORT_WEB}/tcp \
  --cap-add=NET_ADMIN \
  --sysctl="net.ipv4.ip_forward=1" \
  --restart unless-stopped \
  ghcr.io/wg-easy/wg-easy:14 > /dev/null

sleep 2
clear
get_status
# 7. Финальный вопрос: Очистка образов
echo
ask "Очистить неиспользуемые образы? [ENTER - очистить / Любая клавиша - оставить]: "
IFS= read -n 1 -s REPLY; echo ""
if [[ -z "$REPLY" ]]; then
    info "Удаление старых образов..."
    docker image prune -a -f
    echo -e "${GREEN}✅ Диск очищен.${NC}"
else
    info "Образы оставлены в системе."
fi
info "Готово!"
