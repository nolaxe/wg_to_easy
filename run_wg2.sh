#!/bin/bash

clear
# 
echo "Удаление wg-easy"
./del_wg.sh
#

echo "Установка wg-easy v2"
sudo apt update && sudo apt install -y docker.io docker-compose
sudo systemctl enable --now docker

#
read -sp "Enter VPN password: " vpn_password
echo

# 2. Запуск контейнера
if docker pull weejewel/wg-easy:latest >/dev/null 2>&1 || true; then
    if docker run -d \
        --name=wg-easy \
        -e WG_HOST=$(curl -s ifconfig.me) \
        -e PASSWORD="$vpn_password" \
        -p 51820:51820/udp \
        -p 51821:51821/tcp \
        --cap-add=NET_ADMIN \
        --sysctl="net.ipv4.ip_forward=1" \
        --restart unless-stopped \
        weejewel/wg-easy >/dev/null 2>&1; then
        
        # 3. Проверка статуса
        echo -e "\nСтатус контейнера:"
        docker ps -a | grep wg-easy

        # 4. Проверка WG
        echo -e "\nWireGuard статус:"
        docker exec wg-easy wg show

        # 5. Вывод информации
        current_ip=$(curl -s ifconfig.me)
        echo -e "\n\nКонтейнер успешно запущен!"
        echo "WG_HOST=$current_ip"
        echo "PASSWORD=$vpn_password"
        echo -e "Web-интерфейс доступен по адресу: http://$current_ip:51821"
    else
        echo -e "\nОшибка: Не удалось запустить контейнер" >&2
        exit 1
    fi
else
    echo -e "\nОшибка: Не удалось загрузить образ weejewel/wg-easy" >&2
    exit 1
fi
