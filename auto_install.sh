#!/bin/bash

# ЗМІННІ ДЛЯ АВТОРИЗАЦІЇ
DOCKER_USER=${DOCKER_USER:-"your_dockerhub_username"}    # Ім'я користувача Docker Hub
DOCKER_PASS=${DOCKER_PASS:-"your_dockerhub_password"}    # Пароль Docker Hub або токен доступу
GITHUB_USER=${GITHUB_USER:-"your_github_username"}       # Ім'я користувача GitHub
GITHUB_TOKEN=${GITHUB_TOKEN:-"your_github_personal_access_token"}  # Персональний токен GitHub

# Ім'я Docker контейнера
CONTAINER_NAME="site"

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

# Створення SSH ключа, якщо не існує, та автоматичне додавання на GitHub через API
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Створюємо новий SSH ключ..."
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/id_rsa -N ""

    # Запускаємо SSH агент і додаємо ключ
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa

    # Читання публічного ключа
    SSH_KEY=$(cat ~/.ssh/id_rsa.pub)

    # Додавання публічного ключа на GitHub через API
    echo "Додаємо публічний ключ на GitHub через API..."
    curl -H "Authorization: token $GITHUB_TOKEN" \
        --data "{\"title\":\"$(hostname)\",\"key\":\"$SSH_KEY\"}" \
        https://api.github.com/user/keys

    if [ $? -eq 0 ]; then
        echo "SSH ключ успішно додано на GitHub!"
    else
        echo "Помилка при додаванні SSH ключа на GitHub."
        exit 1
    fi
else
    echo "SSH ключ уже існує."
fi

# Перезапуск SSH агента для переконання, що ключ додано
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

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

