#!/bin/bash

ls -al ~/.ssh
ssh-keygen -t ed25519 -C "exalon"

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

cat ~/.ssh/id_ed25519.pub | xclip

# Перейдите в Settings → SSH and GPG keys → New SSH key.
# Вставьте содержимое id_ed25519.pub в поле "Key".

# ssh -T git@github.com
