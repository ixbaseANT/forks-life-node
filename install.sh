#!/bin/bash

# Forks Life Node Installer
# https://github.com/YOUR_USER/forks-life-node

set -e

echo "🛠 Установка Forks Life Explorer..."

echo "📁 Подготовка каталогов..."
sudo mkdir -p /var/www/html
cd /var/www/html

echo "🌐 Установка NGINX..."
sudo apt update
sudo apt install -y nginx

echo "🔧 Настройка NGINX..."
sudo tee /etc/nginx/sites-available/default >/dev/null <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.php index.html index.htm;

    server_name _;

    location /fork/db {
        return 302 /fork;
    }

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

echo "🔄 Перезапуск NGINX..."
sudo systemctl restart nginx

echo "📦 Установка PHP, SQLite и зависимостей..."
sudo apt install -y php php-sqlite3 php-fpm php-curl sqlite3

echo "📦 Загрузка и распаковка Forks Life..."
sudo chown -R www-data:www-data /var/www/html
wget -N https://forks.life/fork.tar.gz -O fork.tar.gz
sudo tar -xzf fork.tar.gz
sudo rm -f fork.tar.gz
sudo chown -R www-data:www-data /var/www/html/fork

echo "🧾 Создание стартовой страницы..."
sudo tee   /var/www/html/index.html >/dev/null <<HTML
<!DOCTYPE html>
<html><head>
<style>
body { margin: 0; background: #000; }
iframe { width: 100%; height: 100%; border: none; }
div { position: fixed; top: 0; bottom: 0; left: 0; right: 0; }
</style>
</head><body>
<div><iframe id=mF src=/fork/v.php?ix=w-home></iframe></div>
</body></html>
HTML

echo "✅ Установка завершена."
echo "🌐 Откройте в браузере: http://localhost/"
