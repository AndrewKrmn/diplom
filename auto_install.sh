#!/bin/bash

# Завантажуємо змінні з файлу .env
if [ -f .env ]; then
    echo "Завантаження змінних з файлу .env..."
    source .env
else
    echo "Файл .env не знайдено!"
    exit 1
fi

# Оновлення та прокачка системних пакетів
sudo apt update && sudo apt upgrade -y

# Перевірка, чи встановлений Docker
if ! command -v docker &> /dev/null
then
    echo "Docker не встановлений. Виконуємо встановлення Docker..."
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    echo "Docker успішно встановлено!"
else
    echo "Docker уже встановлений."
fi

# Переміщення існуючого SSH ключа на AWS машину
echo "Переміщуємо існуючий SSH ключ на AWS..."
scp -i $AWS_KEY_PATH ~/.ssh/id_rsa $AWS_USER@$AWS_HOST:~/.ssh/

if [ $? -ne 0 ]; then
    echo "Помилка при переміщенні SSH ключа на AWS машину."
    exit 1
else
    echo "SSH ключ успішно переміщено на AWS машину."
fi

# Перевірка підключення до GitHub через SSH
echo "Перевіряємо підключення до GitHub..."
ssh -T git@github.com
if [ $? -ne 1 ]; then
    echo "Не вдалося підключитися до GitHub через SSH. Перевірте SSH ключі та права доступу."
    exit 1
else
    echo "Підключення до GitHub через SSH успішне."
fi

# Оновлений SSH URL репозиторію
GIT_REPO_URL="git@github.com:AndrewKrmn/diplom.git"
REPO_DIR="$(basename "$GIT_REPO_URL" .git)"

# Перевірка, чи існує репозиторій
if [ -d "$REPO_DIR" ]; then
    echo "Репозиторій уже існує. Виконуємо git pull..."
    cd "$REPO_DIR"
    git pull
else
    echo "Клонуємо репозиторій..."
    git clone "$GIT_REPO_URL"
    cd "$REPO_DIR"
fi

# Збірка Docker образа і пуш на Docker Hub
IMAGE_NAME="chikibevchik/diplom-site"

docker build -t $IMAGE_NAME .

# Логін у Docker Hub і перевірка успішності
echo docker login --username $DOCKER_USER --password $DOCKER_PASS
if [ $? -ne 0 ]; then
    echo "Не вдалося авторизуватися в Docker Hub. Перевірте ім'я користувача або пароль."
    exit 1
fi

docker push $IMAGE_NAME

# Перевірка, чи контейнер існує, і видалення, якщо так
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "Контейнер $CONTAINER_NAME існує. Видаляємо його..."
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
fi

# Створення і запуск нового контейнера
echo "Створюємо і запускаємо новий контейнер $CONTAINER_NAME..."
docker run -d -p 8082:8080 --restart=always --name $CONTAINER_NAME $IMAGE_NAME

# Перевірка, чи встановлений Docker Compose і запуск
if command -v docker-compose &> /dev/null
then
    docker-compose up -d
else
    echo "Docker Compose не знайдено, встановлюємо..."
    sudo apt-get install -y docker-compose-plugin
    docker compose up -d
fi
