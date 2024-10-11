#!/bin/bash

# Генеруємо SSH-ключ, якщо його ще немає
if [ ! -f /var/jenkins_home/.ssh/id_rsa ]; then
    mkdir -p /var/jenkins_home/.ssh
    ssh-keygen -t rsa -b 4096 -N "" -f /var/jenkins_home/.ssh/id_rsa -C "jenkins@example.com"
    chown -R jenkins:jenkins /var/jenkins_home/.ssh
    chmod 700 /var/jenkins_home/.ssh
    chmod 600 /var/jenkins_home/.ssh/id_rsa
    chmod 644 /var/jenkins_home/.ssh/id_rsa.pub
fi

# Додаємо Git-сервер до known_hosts
if [ ! -f /var/jenkins_home/.ssh/known_hosts ]; then
    touch /var/jenkins_home/.ssh/known_hosts
    ssh-keyscan github.com >> /var/jenkins_home/.ssh/known_hosts
    chown jenkins:jenkins /var/jenkins_home/.ssh/known_hosts
    chmod 644 /var/jenkins_home/.ssh/known_hosts
fi

# Запускаємо Jenkins
exec /usr/local/bin/jenkins.sh

