# 🧰 Forks Life Node Setup

Установка и настройка Forks Life Wallet на сервере (Orange Pi, Ubuntu и др).

## 📦 Что делает скрипт:

- Устанавливает `nginx`, `php`, `sqlite3`
- Конфигурирует nginx для PHP
- Загружает и разворачивает Forks Life Explorer
- Создаёт стартовую страницу

## 🚀 Установка

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ixbaseANT/forks-life-node/main/install.sh)
```

## 🔗 Стартовая страница

После установки:  
📂 `http://localhost/fork`


/*
дооформить дополнительные права управления сервером и форками для github
*/

Дополнительные права.

Для предоставления дополнительных прав необходимо отредактировать файл /etc/sudoers

Добавьте строку для веб-пользователя.
Например, если веб-сервер работает от имени www-data
 и вы хотите разрешить ему перезапускать Nginx и форки,
 добавьте такие строки в конец файла: 
   /etc/sudoers

Код

www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx

www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart bitmemed
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable  bitmemed
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart bitmemewallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable  bitmemewallet

www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart bricsd
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable  bricsd
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart bricswallllet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable  bricswallet

www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart gord
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable  gord
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart gorwallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable  gorwallet

www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart caspad
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable  caspad
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart caswallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable  caswallet

www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart kasv2d
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable  kasv2d
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart kasv2wallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable  kasv2wallet

www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart kaspa
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable  kaspa
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart kaspawallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable  kaspawallet

Подставляйте только те команды, которые действительно необходимы.

Теперь PHP-скрипт сможет выполнить команду exec('sudo systemctl restart nginx')


## 🛡 Лицензия

MIT License
