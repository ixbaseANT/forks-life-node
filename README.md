# 🧰 Forks Life Node Setup
Установка и настройка Forks Life Wallet на сервере (Orange Pi, Ubuntu и другие дистрибутивы Linux).

## 📦 Возможности скрипта
Установка базового ПО: Автоматическая установка nginx, php-fpm, sqlite3 и других зависимостей.

Веб-сервер: Конфигурация nginx для обработки PHP-запросов.

Forks Life Explorer: Загрузка и развёртывание последней версии веб-интерфейса Forks Life.

Стартовая страница: Создание информационной панели для доступа к кошельку по адресу http://<ваш-ip>/fork.

## 🚀 Быстрая установка
Выполните следующую команду на вашем сервере:

bash
bash <(curl -fsSL https://raw.githubusercontent.com/ixbaseANT/forks-life-node/main/install.sh)

## 🔗 Доступ после установки
После успешного завершения скрипта откройте браузер и перейдите по адресу:
📂 http://localhost/fork (локально) или http://<IP-адрес-вашего-сервера>/fork

## ⚙️ Настройка дополнительных прав (для управления сервисами)
Для работы функций управления нодами (перезапуск, включение) из веб-интерфейса, PHP-скриптам необходимо дать права на выполнение системных команд systemctl через sudo.

Внимание: Это действие требует осторожности, так как связано с изменением прав доступа.

Шаг 1: Создание файла конфигурации sudo (Рекомендуемый способ)
Не редактируйте файл /etc/sudoers напрямую. Вместо этого создайте новый файл конфигурации:

bash
sudo nano /etc/sudoers.d/forks-life-web
Шаг 2: Добавление правил для веб-сервера
Вставьте в открывшийся файл следующий код. Замените www-data на пользователя, от которого работает ваш веб-сервер (nginx/Apache), если это не так.

bash
## Разрешить управление nginx
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl reload nginx

## Разрешить управление сервисами форков
## BitMemo (BITMEM)
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart bitmemed
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable bitmemed
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart bitmemewallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable bitmemewallet

## Brics (BRC20)
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart bricsd
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable bricsd
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart bricswallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable bricswallet

## Gordian (GORD)
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart gord
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable gord
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart gorwallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable gorwallet

## Caspian (CAS)
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart caspad
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable caspad
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart caswallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable caswallet

## Kaspa V2 (KASV2)
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart kasv2d
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable kasv2d
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart kasv2wallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable kasv2wallet

## Kaspa (KAS)
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart kaspa
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable kaspa
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart kaspawallet
www-data ALL=(ALL) NOPASSWD: /usr/bin/systemctl enable kaspawallet
Важно: Оставьте только те строки, которые соответствуют установленным на вашем сервере форкам. Не нужно разрешать то, что у вас не используется.

Шаг 3: Установка корректных прав на файл
Обязательно установите правильные права на созданный файл, иначе система проигнорирует его:

bash
sudo chmod 0440 /etc/sudoers.d/forks-life-web
Проверка
После настройки PHP-скрипты Forks Life смогут выполнять команды типа:

php
exec('sudo systemctl restart nginx');
exec('sudo systemctl restart bitmemed');
без запроса пароля.

## 🔐 Рекомендации по безопасности
Минимальные привилегии: Предоставляйте права только на конкретные, необходимые команды, как показано в примере.

Брандмауэр: Настройте фаервол (например, ufw), чтобы открыть только необходимые порты (80, 443, и порты для форков).

SSL/HTTPS: Настоятельно рекомендуется настроить шифрование HTTPS с помощью Let's Encrypt (Certbot) для защиты передаваемых данных.

Доступ по SSH: Используйте аутентификацию по ключу, а не по паролю, для SSH-доступа к серверу.

## 🛠 Устранение неполадок
"Permission denied" при выполнении команд из веб-интерфейса: Убедитесь, что пользователь веб-сервера (www-data, nginx) указан верно и файл в /etc/sudoers.d/ имеет права 0440.

Страница не найдена (404): Проверьте, успешно ли завершилась установка nginx и PHP. Убедитесь, что файлы были загружены в правильную директорию (обычно /var/www/html/).

## 🛡 Лицензия
Проект распространяется под лицензией MIT License.
