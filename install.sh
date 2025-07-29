#!/bin/bash

# Forks Life Node Installer
# https://github.com/YOUR_USER/forks-life-node

set -e

echo "🛠 Установка Forks Life Explorer..."

echo "📁 Подготовка каталогов..."
sudo mkdir -p /var/www/html/cgi-bin
sudo mkdir -p /var/www/html/fork/db
cd /var/www/html

echo "🌐 Установка NGINX и FastCGI..."
sudo apt update
sudo apt install -y nginx fcgiwrap spawn-fcgi

echo "📦 Установка PHP, SQLite и Python-зависимостей..."
sudo apt install -y php php-sqlite3 php-fpm php-curl php-xml sqlite3 python3 python3-pip

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

    location /cgi-bin/ {
        gzip off;
        root /var/www/html;
        fastcgi_pass unix:/var/run/fcgiwrap.socket;
        include /etc/nginx/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME /var/www/html\$fastcgi_script_name;
        fastcgi_param QUERY_STRING \$query_string;
        fastcgi_param REQUEST_METHOD \$request_method;
        fastcgi_param CONTENT_TYPE \$content_type;
        fastcgi_param CONTENT_LENGTH \$content_length;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

echo "🔄 Перезапуск NGINX и fcgiwrap..."
sudo systemctl enable fcgiwrap
sudo systemctl restart fcgiwrap
sudo systemctl restart nginx
sudo systemctl restart php*-fpm

echo "📦 Загрузка и распаковка Forks Life..."
sudo chown -R www-data:www-data /var/www/html
sudo wget -N https://forks.life/fork.tar.gz -O fork.tar.gz
sudo tar -xzf fork.tar.gz
sudo rm -f fork.tar.gz
sudo chown -R www-data:www-data /var/www/html/fork

echo "🐍 Создание примера CGI-скрипта для DBF..."
sudo tee /var/www/html/cgi-bin/dbf_peers.py >/dev/null <<PY
#!/usr/bin/env python3
from dbfread import DBF
import json

print("Content-Type: application/json\n")

try:
    records = [r for r in DBF('/var/www/html/fork/db/peers.dbf')]
    print(json.dumps(records, indent=2, ensure_ascii=False))
except Exception as e:
    print(json.dumps({"error": str(e)}))
PY

sudo chmod +x /var/www/html/cgi-bin/dbf_peers.py

echo "🧾 Создание стартовой страницы..."
sudo tee /var/www/html/index.html >/dev/null <<HTML
<!DOCTYPE html>
<html><head>
<style>
body { margin: 0; background: #000; }
iframe { width: 100%; height: 100%; border: none; }
div { position: fixed; top: 0; bottom: 0; left: 0; right: 0; }
</style>
</head><body>
<div><iframe id=mF src=/fork/v.php?ix=w-utx></iframe></div>
</body></html>
HTML

echo "✅ Установка завершена."
echo "🌐 Откройте в браузере: http://localhost/"
echo "🔍 Пример CGI DBF endpoint: http://localhost/cgi-bin/dbf"
