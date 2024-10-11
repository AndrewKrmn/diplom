pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker')
        IMAGE_NAME = 'chikibevchik/diplom-site'
        CONTAINER_NAME = 'site' 
    }

    stages {
        stage('Clone repository') {
            steps {
                git branch: 'main', url: 'git@github.com:AndrewKrmn/diplom.git'
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
        stage('Remove Existing Container') {
            steps {
                script {
                    sh '''
                    if [ $(docker ps -q -f name=$CONTAINER_NAME) ]; then
                        docker stop $CONTAINER_NAME
                        docker rm $CONTAINER_NAME
                    fi
                    '''
                }
            }
        }
        stage('Run New Container') {
            steps {
                sh 'docker run -d -p 8080:8080 --net="host" --pid="host" --restart=always --name $CONTAINER_NAME $IMAGE_NAME'
            }
        }
        stage('Deploy Containers') {
            steps {
                script {
                    sh 'docker-compose up'
                }
            }
        }
    }
    post {
        always {
            sh 'docker logout'
        }
    }
}