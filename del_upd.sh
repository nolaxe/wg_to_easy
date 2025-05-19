#!/bin/bash

# Находим контейнер WG-Easy (по маске 'wg' в имени)
WG_CONTAINER=$(docker ps -a --format "{{.Names}}" | grep -i "wg" | head -n 1)

if [ -z "$WG_CONTAINER" ]; then
    echo "❌ Контейнер WG-Easy не найден!"
    exit 1
fi

echo "Найден контейнер: $WG_CONTAINER"

read -p "Убрать плашку 'Доступно обновление' (docker cp app.js ${WG_CONTAINER}:/app/www/js/app.js)? (y/n) " choice

if [[ "$choice" =~ [yY] ]]; then
    echo "Загружаю файлы..."
    curl -sSL https://raw.githubusercontent.com/nolaxe/wg_to_easy/main/app_no_upd.js -o app.js
    curl -sSL https://raw.githubusercontent.com/nolaxe/wg_to_easy/main/bender.png -o logo.png

    echo "Копирую в контейнер ${WG_CONTAINER}..."
    docker cp app.js ${WG_CONTAINER}:/app/www/js/app.js
    docker cp logo.png ${WG_CONTAINER}:/app/www/img/logo.png
    rm -f app.js logo.png

    echo "✅ Готово! Контейнер ${WG_CONTAINER} обновлен."
else
    echo "ℹ️ Отмена."
    exit 0
fi
