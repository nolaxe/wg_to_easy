docker stop wg-easy # Остановить контейнер wg-easy
# docker stop $(docker ps -aq)  # Остановить все

# Удалить контейнер wg-easy (после остановки)
docker rm wg-easy
# docker rm $(docker ps -aq)    # Удалить все

# Принудительно остановить и удалить контейнер (если не останавливается)
# docker rm -f wg-easy

# Просмотреть список всех контейнеров (для проверки)
docker ps -a

# Удалить образ weejewel/wg-easy (если нужно)
docker rmi weejewel/wg-easy

# Просмотреть список образов (для проверки)
docker images

docker system prune -a # Очистить систему Docker (удалить остановленные контейнеры, неиспользуемые сети и образы)
docker system prune -af # ... (без подтверждения)


