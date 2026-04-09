#!/bin/bash

# Проверка на существование ключа
if [ -f ~/.ssh/id_ed25519 ]; then
    echo "⚠️  Ключ уже существует. Перезаписать? (y/N)"
    read -r answer
    [[ "$answer" != "y" && "$answer" != "Y" ]] && exit 1
fi

# Генерация ключа
ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)-$(date +%Y-%m-%d)" -f ~/.ssh/id_ed25519

# Запуск агента и добавление ключа
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Копирование в буфер (кросс-платформенно)
if command -v xclip &> /dev/null; then
    cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard
    echo "✅ Ключ скопирован в буфер (xclip)"
elif command -v pbcopy &> /dev/null; then
    cat ~/.ssh/id_ed25519.pub | pbcopy
    echo "✅ Ключ скопирован в буфер (pbcopy)"
elif command -v clip.exe &> /dev/null; then
    cat ~/.ssh/id_ed25519.pub | clip.exe
    echo "✅ Ключ скопирован в буфер (Windows clip)"
else
    echo "❌ Не найдена утилита для копирования в буфер"
    cat ~/.ssh/id_ed25519.pub
fi

echo -e "\n📋 Публичный ключ (скопирован):"
echo "-----------------------------------"
cat ~/.ssh/id_ed25519.pub
echo "-----------------------------------"
echo -e "\n🔗 Добавьте его в GitHub: https://github.com/settings/keys"
echo "🧪 Проверка подключения: ssh -T git@github.com"
