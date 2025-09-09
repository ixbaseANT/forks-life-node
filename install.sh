#!/bin/bash

# Forks Life Node Installer
# https://github.com/ixbaseANT/forks-life-node

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
sudo apt install python3.11-venv -y

echo "🐍 Создание Python venv..."
cd /var/www/html/fork
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install bip-utils
deactivate
cd /var/www/html

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
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
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

echo "🔑 Настройка логинов и паролей..."

# Папка под приватные данные
sudo mkdir -p /var/www/html/fork/db
sudo chown www-data:www-data /var/www/html/fork/db
sudo chmod 700 /var/www/html/fork/db

# Определяем текущего пользователя и его домашнюю папку
CURRENT_USER=$(whoami)
CURRENT_HOME=$HOME

# Берём значения из окружения или ставим дефолты
APP_USER=${APP_USER:-user}
APP_PASS=${APP_PASS:-12!}
SYS_USER=${SYS_USER:-admin}
SYS_PASS=${SYS_PASS:-!21}

# Дополнительно сохраняем имя текущего пользователя и его home
HOST_USER=$CURRENT_USER
HOST_HOME=$CURRENT_HOME

CRED_FILE="/var/www/html/fork/db/credentials.env"

cat <<EOF | sudo tee $CRED_FILE >/dev/null
# Forks Life credentials (non-interactive install)
APP_USER=$APP_USER
APP_PASS=$APP_PASS
SYS_USER=$SYS_USER
SYS_PASS=$SYS_PASS

# System info
HOST_USER=$HOST_USER
HOST_HOME=$HOST_HOME
EOF

sudo chown root:www-data $CRED_FILE
sudo chmod 640 $CRED_FILE

echo "🌐 Создание стартовой страницы с системной информацией..."
sudo tee /var/www/html/index.php >/dev/null <<'EOF'
<?php
$credFile = "/var/www/html/fork/db/credentials.env";
$creds = [];
if (file_exists($credFile)) {
    $lines = file($credFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, "=") !== false && substr(trim($line), 0, 1) !== "#") {
            list($k, $v) = explode("=", $line, 2);
            $creds[$k] = $v;
        }
    }
}
?>
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8">
  <title>Forks Life Node — Системная информация</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    h2 { color: #444; }
    table { border-collapse: collapse; width: 60%; }
    th, td { border: 1px solid #ccc; padding: 8px; }
    th { background: #f0f0f0; text-align: left; }
  </style>
</head>
<body>
  <h2>🚀 Forks Life Node — Системная информация</h2>
  <table>
    <tr><th>APP_USER</th><td><?= htmlspecialchars($creds['APP_USER'] ?? '') ?></td></tr>
    <tr><th>APP_PASS</th><td><?= htmlspecialchars($creds['APP_PASS'] ?? '') ?></td></tr>
    <tr><th>SYS_USER</th><td><?= htmlspecialchars($creds['SYS_USER'] ?? '') ?></td></tr>
    <tr><th>SYS_PASS</th><td><?= htmlspecialchars($creds['SYS_PASS'] ?? '') ?></td></tr>
    <tr><th>HOST_USER</th><td><?= htmlspecialchars($creds['HOST_USER'] ?? '') ?></td></tr>
    <tr><th>HOST_HOME</th><td><?= htmlspecialchars($creds['HOST_HOME'] ?? '') ?></td></tr>
  </table>
  <br>
  <a href="/fork/index-fork.html">🔗 Перейти к Explorer</a>
</body>
</html>
EOF

echo
echo "📋 Итоговые параметры:"
echo "  APP_USER  = $APP_USER"
echo "  APP_PASS  = $APP_PASS"
echo "  SYS_USER  = $SYS_USER"
echo "  SYS_PASS  = $SYS_PASS"
echo "  HOST_USER = $HOST_USER"
echo "  HOST_HOME = $HOST_HOME"
echo

echo "✅ Установка завершена."
echo "🌐 Откройте в браузере: http://localhost/"
echo "🔍 Пример CGI DBF endpoint: http://localhost/cgi-bin/dbf"
