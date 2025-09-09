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
sudo -u www-data bash -c '
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
sudo cp /var/www/html/fork/index-fork.html /var/www/html/index.html
sudo chown -R www-data:www-data /var/www/html/fork

echo "🔑 Настройка логинов и паролей..."

# Папка под приватные данные
sudo mkdir -p /var/www/html/fork/db
sudo chown www-data:www-data /var/www/html/fork/db
sudo chmod 700 /var/www/html/fork/db

# Спросим данные с дефолтами
read -p "Введите APP_USER (по умолчанию: user): " APP_USER
APP_USER=${APP_USER:-user}

read -p "Введите APP_PASS (по умолчанию: 12!): " APP_PASS
APP_PASS=${APP_PASS:-12!}

read -p "Введите SYS_USER (по умолчанию: admin): " SYS_USER
SYS_USER=${SYS_USER:-admin}

read -p "Введите SYS_PASS (по умолчанию: !21): " SYS_PASS
SYS_PASS=${SYS_PASS:-!21}

# Записываем креды в файл (ограниченный доступ)
CRED_FILE="/var/www/html/fork/db/credentials.env"

cat <<EOF | sudo tee $CRED_FILE >/dev/null
# Forks Life credentials
APP_USER=$APP_USER
APP_PASS=$APP_PASS
SYS_USER=$SYS_USER
SYS_PASS=$SYS_PASS
EOF

sudo chown root:www-data $CRED_FILE
sudo chmod 640 $CRED_FILE

echo "✅ Логины/пароли сохранены в $CRED_FILE (чтение только root и www-data)"

echo "✅ Установка завершена."
echo "🌐 Откройте в браузере: http://localhost/"
echo "🔍 Пример CGI DBF endpoint: http://localhost/cgi-bin/dbf"

