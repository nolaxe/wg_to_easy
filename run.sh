#!/bin/bash

echo "Выберите версию для запуска:"
echo "1) Версия 1 "
echo "2) Версия 2 "
read -p "Введите 1 или 2: " choice

case $choice in
    1)
        echo "Запускаем версию 1..."
        https://raw.githubusercontent.com/nolaxe/wg_to_easy/main/run_wg1.sh
        ;;
    2)
        echo "Запускаем версию 2..."
        https://raw.githubusercontent.com/nolaxe/wg_to_easy/main/run_wg2.sh
        ;;
    *)
        echo "Ошибка: неверный выбор. Введите 1 или 2."
        exit 1
        ;;
esac
