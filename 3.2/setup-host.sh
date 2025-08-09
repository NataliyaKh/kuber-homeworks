#!/bin/bash

read -p "Введите новый hostname: " NEW_HOSTNAME

echo "[1/6] Установка hostname: $NEW_HOSTNAME"
sudo hostnamectl set-hostname "$NEW_HOSTNAME"

echo "[2/6] Обновление cloud.cfg (отключаем manage_etc_hosts)"
CLOUD_CFG="/etc/cloud/cloud.cfg"
if grep -q "^manage_etc_hosts:" "$CLOUD_CFG"; then
    sudo sed -i 's/^manage_etc_hosts:.*/manage_etc_hosts: false/' "$CLOUD_CFG"
else
    echo "manage_etc_hosts: false" | sudo tee -a "$CLOUD_CFG" > /dev/null
fi

echo "[3/6] Удаление шаблона hosts.debian.tmpl (при наличии)"
sudo rm -f /etc/cloud/templates/hosts.debian.tmpl

echo "[4/6] Обновление /etc/hosts"
# Удалим старую строку 127.0.1.1, если есть
sudo sed -i '/^127\.0\.1\.1/d' /etc/hosts
# Добавим новую строку
echo "127.0.1.1 $NEW_HOSTNAME" | sudo tee -a /etc/hosts > /dev/null

echo "[5/6] Проверка:"
hostname
echo "------ /etc/hosts -------"
grep 127.0.1.1 /etc/hosts
echo "--------------------------"

echo "[6/6] Готово. Сейчас будет перезагрузка."
read -p "Нажмите Enter для перезагрузки или Ctrl+C для отмены."
sudo reboot
