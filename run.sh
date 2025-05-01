#!/bin/bash

# Функция для загрузки скрипта с GitHub +
download_script() {
    local script_name=$1
    local url="https://raw.githubusercontent.com/nolaxe/wg_to_easy/main/$script_name"
    
    echo "Загрузка $script_name..."
    if ! curl -sSLf "$url" -o "$script_name"; then
        echo "Ошибка: не удалось загрузить $script_name"
        exit 1
    fi
    chmod +x "$script_name"
    echo "$script_name успешно загружен и добавлен в текущую директорию."
}

# Проверяем наличие run_wg1.sh и run_wg2.sh, загружаем при необходимости
if [ ! -f "./run_wg1.sh" ]; then
    download_script "run_wg1.sh"
fi

if [ ! -f "./run_wg2.sh" ]; then
    download_script "run_wg2.sh"
fi

# Меню выбора
echo "Выберите версию для запуска:"
echo "Версия 1 (run_wg1.sh)"
echo "Версия 2 (run_wg2.sh)"
read -p "Введите 1 или 2: " choice

case $choice in
    1)
        echo "Запускаем версию 1..."
        ./run_wg1.sh
        ;;
    2)
        echo "Запускаем версию 2..."
        ./run_wg2.sh
        ;;
    *)
        echo "Ошибка: неверный выбор. Введите 1 или 2."
        exit 1
        ;;
esac
