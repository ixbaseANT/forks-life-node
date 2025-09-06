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
sudo apt install -y php php-sqlite3 php-fpm php-curl php-xml sqlite3 python3 python3-pip python3-venv

echo "🐍 Создание Python venv..."
cd /var/www/html/fork
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install bip-utils
deactivate

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

echo "🐍 Создание CGI-скрипта derive_keys.py..."
sudo tee /var/www/html/cgi-bin/derive_keys.py >/dev/null <<'PY'
#!/usr/bin/env /var/www/html/fork/venv/bin/python
import os, sys, json, re, subprocess
from bip_utils import Bip39SeedGenerator, Bip32Slip10Secp256k1

print("Content-Type: application/json\n")

HD_PATHS = {
    "kas": "m/44'/16180'/0'/0/0/0",
    "gor": "m/44'/111111'/0'/0/0/0",
    "btm": "m/44'/222222'/0'/0/0/0",
    "bri": "m/44'/333333'/0'/0/0/0",
    "cas": "m/44'/444444'/0'/0/0/0",
    "kv2": "m/44'/555555'/0'/0/0/0",
    "btc": "m/44'/0'/0'/0/0/0"
}

qs = os.environ.get("QUERY_STRING", "")
params = dict(p.split("=", 1) for p in qs.split("&") if "=" in p)
coin = params.get("coin", "gor")

if coin not in HD_PATHS:
    print(json.dumps({"error": f"Unsupported coin: {coin}"}))
    sys.exit(0)

try:
    raw = subprocess.check_output(
        [f"./{coin}wallet", "dump-unencrypted-data", "-y", "--password=1"],
        text=True
    )
except Exception as e:
    print(json.dumps({"error": f"wallet exec failed: {e}"}))
    sys.exit(0)

match = re.search(r"Mnemonic #1:\s*(.+?)\s*Minimum number", raw, re.S)
if not match:
    print(json.dumps({"error": "Mnemonic not found in wallet output"}))
    sys.exit(0)

mnemonic = match.group(1).strip()

path = HD_PATHS[coin]
seed_bytes = Bip39SeedGenerator(mnemonic).Generate()
bip32_ctx = Bip32Slip10Secp256k1.FromSeed(seed_bytes)
derived = bip32_ctx.DerivePath(path)

priv_key = "0x" + derived.PrivateKey().Raw().ToHex()
pub_key  = "0x" + derived.PublicKey().RawCompressed().ToHex()

result = {
    "coin": coin,
    "hd_path": path,
    "privateKey": priv_key,
    "publicKey": pub_key,
}

print(json.dumps(result, indent=2))
PY

sudo chmod +x /var/www/html/cgi-bin/derive_keys.py

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
echo "🔑 Пример derive_keys endpoint: http://localhost/cgi-bin/derive_keys.py?coin=gor"
