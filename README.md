# Дипломна робота команда Spotify
Дипломна робота DevOps'a команди Spotify

## Вміст
- [Технології](#технології)
- [Початок роботи](#початок-роботи)
- [Deploy і CI/CD](#deploy-і-ci/cd)
- [Contributing](#contributing)
- [To do](#to-do)
- [Команда проекта](#команда-проекта)

## Технології
- [AWS](https://aws.amazon.com/ru/)
- [Docker](https://www.docker.com/)
- [K8s](https://kubernetes.io/)
- [Grafana](https://grafana.com/)
- [Prometheus](https://prometheus.io/)
- [Terraform](https://www.terraform.io/)

## Використання
Завантажуємо репозиторій:
```sh
git clone https://github.com/AndrewKrmn/diplom.git
```
```sh
cd diplom/
```
Ініціалізуєм терафому:
```sh
terraform init
```
Запускаємо перший інстанс:
```sh
terraform apply
```
Заходим через будь-який ssh клієнт на інстанс
створюємо ssh ключі і добавляємо в Github:
```sh
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/id_rsa -N ""
```
Тепер знову клоним репозиторій:
```sh
git clone https://github.com/AndrewKrmn/diplom.git
cd diplom/
```
Запускаєм скрипт auto_install.sh:
```sh
bash auto_install.sh
```
Встановлення filebeat:
```sh
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.15.2-linux-x86_64.tar.gz
tar xzvf filebeat-8.15.2-linux-x86_64.tar.gz
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update
sudo apt-get install filebeat
```
Конфігурування filebeat:
```sh
vim /etc/filebeat/filebeat.yml
міняєм перший false на true
scan_frequency: 8h
розкомітить логін і пароль(пароль поміняти на свій)
перший localhost поміняти на ip ELK
```
Після чого будуть доступні такі сервіси:
```sh
site http://ropsten.ethers.io/#!/app-link-insecure/localhost:8080/
grafana http://localhost:3000
prometheus http://localhost:9090
alert manager http://localhost:9093
node exporter http://localhost:9100
cadvisor http://localhost:8081
blackbox exporter http://localhost:9115
```
Запуск ELK stack:
```sh
cd elk/
terraform init
terraform apply
```
Також заходим на elk інстанс чекаєм поки скрипт встановить все після чого прописуєм таку команду:
```sh
sudo /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive
і вводим 10 разів пароль
```
