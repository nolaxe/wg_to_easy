clear
# Остановить контейнер wg-easy
docker stop wg-easy && echo "Контейнер wg-easy успешно остановлен" || echo "Ошибка остановки контейнера"
# docker stop $(docker ps -aq)  # Остановить все

# Удалить контейнер wg-easy (после остановки)
docker rm wg-easy && echo "Контейнер wg-easy успешно удален" || echo "Ошибка удаления контейнера"
# docker rm $(docker ps -aq)    # Удалить все

# Принудительно остановить и удалить контейнер (если не останавливается)
# docker rm -f wg-easy

# Просмотреть список всех контейнеров (для проверки)
echo "Текущие контейнеры:"
docker ps -a

# Удалить образ weejewel/wg-easy (если нужно)
docker rmi weejewel/wg-easy && echo "Образ weejewel/wg-easy успешно удален" || echo "Ошибка удаления образа"

# Просмотреть список образов (для проверки)
echo "Оставшиеся образы:"
docker images

# docker system prune -a # Очистить систему Docker (удалить остановленные контейнеры, неиспользуемые сети и образы)
# !... (без подтверждения)
docker system prune -af && echo "Docker система полностью очищена" || echo "Ошибка очистки системы"

# Финальная проверка
echo "Финальное состояние:"
echo "Контейнеры:" && docker ps -a
echo "Образы:" && docker images
echo "Тома:" && docker volume ls
echo "Сети:" && docker network ls
