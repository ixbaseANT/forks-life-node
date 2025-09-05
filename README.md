# 🧰 Forks Life Node Setup  
Установка и настройка **Forks Life Wallet** на сервере (Orange Pi, Ubuntu и другие дистрибутивы Linux).

---

## 📦 Возможности скрипта

- **Установка базового ПО**: nginx, php-fpm, sqlite3 и другие зависимости.  
- **Веб-сервер**: конфигурация nginx для обработки PHP-запросов.  
- **Forks Life Explorer**: загрузка и развёртывание последней версии веб-интерфейса.  
- **Стартовая страница**: доступ к кошельку по адресу `http://<ваш-ip>/fork`.  

---

## 🚀 Быстрая установка

Выполните на сервере:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ixbaseANT/forks-life-node/main/install.sh)
```

---

## 🔗 Доступ после установки

- 📂 Локально: [http://localhost/fork](http://localhost/fork)  
- 📂 Удалённо: `http://<IP-адрес-вашего-сервера>/fork`  

---

## ⚙️ Настройка дополнительных прав (для управления сервисами)

Чтобы веб-интерфейс мог управлять сервисами (перезапуск, включение), PHP-скриптам нужно дать права на выполнение `systemctl`.

⚠️ **Осторожно!** Это связано с изменением прав доступа.

### Шаг 1. Создайте конфигурацию sudo (Рекомендуемый способ)

Не редактируйте файл /etc/sudoers напрямую. Вместо этого создайте новый файл конфигурации:

```bash
sudo nano /etc/sudoers.d/forks-life-web
```

### Шаг 2. Добавьте правила

Вставьте в открывшийся файл следующий код. Замените www-data на пользователя, от которого работает ваш веб-сервер (nginx/Apache), если это не так.

Пример (замените `www-data` на пользователя вашего веб-сервера):

```bash
# Управление nginx
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl reload nginx

# Bitmeme (BTM)
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart bitmemed
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable bitmemed
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart bitmemewallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable bitmemewallet

# Brics (BRI)
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart bricsd
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable bricsd
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart bricswallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable bricswallet

# Gorbaniov (GOR)
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart gord
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable gord
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart gorwallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable gorwallet

# KaspaClassic (CAS)
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart caspad
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable caspad
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart caswallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable caswallet

# KaspaV2 (KV2)
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart kasv2d
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable kasv2d
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart kasv2wallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable kasv2wallet

# Kaspa (KAS)
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart kaspa
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable kaspa
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart kaspawallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable kaspawallet
```

👉 Оставьте только нужные строки для установленных форков.

### Шаг 3. Права на файл

```bash
sudo chmod 0440 /etc/sudoers.d/forks-life-web
```

После этого PHP-скрипты смогут выполнять команды, например:

```php
exec('sudo systemctl restart nginx');
exec('sudo systemctl restart bitmemed');
```

---

## 🔐 Рекомендации по безопасности

- Минимизируйте привилегии — давайте права только на нужные команды.  
- Настройте **фаервол** (`ufw`): откройте только порты `80`, `443`, и нужные для форков.  
- Используйте **SSL (HTTPS)** — например, с [Let's Encrypt (Certbot)](https://certbot.eff.org/).  
- Для SSH-доступа используйте **ключи вместо паролей**.  

---

## 🛠 Устранение неполадок

- **Permission denied**: проверьте имя пользователя веб-сервера и права на файл `0440`.  
- **Ошибка 404**: убедитесь, что nginx и PHP установлены, а файлы попали в `/var/www/html/`.  

---

## 🛡 Лицензия

Проект распространяется под лицензией **MIT License**.
