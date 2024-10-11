pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker') // ID ваших креденшіалс для Docker Hub
        IMAGE_NAME = 'chikibevchik/diplom-site'
    }

    stages {
        stage('Clone repository') {
            steps {
                git branch: 'main', url: 'git@github.com:AndrewKrmn/diplom.git',credentialsId: 'git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t $IMAGE_NAME .'
                }
            }
        }
        stage('Push Image to Docker Hub') {
            steps {
                script {
                    sh "echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin"
                    sh "docker push $IMAGE_NAME"
                }
            }
        }
        stage('Run Tests') {
            steps {
                // Ваші тести
                sh 'docker run --rm $IMAGE_NAME pytest tests/'
            }
        }
        stage('Deploy Containers') {
            steps {
                // Запуск інших контейнерів
                sh 'docker-compose up -d'
            }
        }
    }
    post {
        always {
            sh 'docker logout'
        }
    }
}
