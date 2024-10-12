#!/bin/bash

# Оновлення системи
echo "Проводимо оновлення системи..."
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install apt-transport-https -y

# Встановлення Docker
echo "Docker is not installed, installing Docker and Docker Compose"
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo usermod -aG docker $USER

echo "Інсталяція Java..."
sudo apt-get install openjdk-17-jdk -y

# Додавання репозиторію Elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo tee /etc/apt/trusted.gpg.d/elasticsearch.asc
sudo sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'
sudo apt-get update -y && sudo apt-get install elasticsearch -y

# Створення директорії для логів Elasticsearch
sudo mkdir -p /usr/share/elasticsearch/logs
sudo chown -R elasticsearch:elasticsearch /usr/share/elasticsearch
sudo chmod -R 755 /usr/share/elasticsearch

# Налаштування Elasticsearch
cat <<EOT > /etc/elasticsearch/elasticsearch.yml
cluster.name: "elk-aws-cluster"
node.name: node-1
discovery.type: single-node
network.host: 0.0.0.0
http.port: 9200
xpack.security.enabled: true
xpack.security.authc.api_key.enabled: true
EOT

# Запуск служби Elasticsearch
echo "Стартуємо Elasticsearch..."
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

# Інсталяція Kibana
echo "Інсталюємо Kibana..."
sudo apt-get install kibana -y

# Налаштування Kibana
echo "Конфігурація Kibana..."
cat <<EOF > /etc/kibana/kibana.yml
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://44.210.166.78:9200"]
elasticsearch.username: "elastic"
elasticsearch.password: "Qwerty-1"
EOF

# Запуск служби Kibana
echo "Запускаємо Kibana..."
sudo systemctl enable kibana
sudo systemctl start kibana

# Встановлення Logstash
echo "Інсталяція Logstash..."
sudo apt-get install logstash -y

# Налаштування Logstash
echo "Конфігуруємо Logstash..."
cat <<EOF > /etc/logstash/conf.d/logstash.conf
input {
  beats {
    port => 5044
  }
}
output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "logstash-%{+YYYY.MM.dd}"
  }
}
EOF

# Запуск служби Logstash
echo "Старт Logstash..."
sudo systemctl enable logstash
sudo systemctl start logstash

# запуск Node-Exporter
sudo docker run -d --name node-exporter -p 9100:9100 prom/node-exporter

# Перевірка статусу сервісів
echo "Перевіряємо статус сервісів ELK:"
sudo systemctl status elasticsearch 
sudo systemctl status kibana
sudo systemctl status logstash