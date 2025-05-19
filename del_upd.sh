###########################
read -p "Убрать плашку веб интерфейса -Доступно обновление- (docker cp app.js wg-easy:/app/www/js/app.js) ? (y/n) " choice
if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    # Загрузка файлов
    echo "Загружаю файлы..."    
    curl -sSL https://raw.githubusercontent.com/nolaxe/wg_to_easy/main/app_no_upd.js -o app.js
    curl -sSL https://raw.githubusercontent.com/nolaxe/wg_to_easy/main/bender.png -o logo.png
    
    echo "Копирую в контейнер..."
    docker cp app.js wg-easy:/app/www/js/app.js
    docker cp logo.png wg-easy:/app/www/img/logo.png
    
    rm -f app.js logo.png
    
    echo "✅ Готово!"
else
    echo "ℹ️ Отмена."
    exit 0
fi
