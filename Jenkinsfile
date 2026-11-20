pipeline {
    agent any

    options {
        // Защита от зависаний и забивания диска
        timeout(time: 20, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '15', artifactNumToKeepStr: '5'))
        disableConcurrentBuilds()
    }

    parameters {
        string(name: 'APP_VERSION', defaultValue: '1.0.0', description: 'Версия приложения')
        choice(name: 'DEPLOY_ENV', choices: ['staging', 'production'], description: 'Окружение')
    }

    environment {
        APP_NAME = 'my-app'
        // Уникальный тег: версия + номер билда + короткий SHA коммита
        IMAGE_TAG = "${params.APP_VERSION}-${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                // Лучшая практика: всегда начинаем с чистого листа
                cleanWs()
                checkout scm
                sh 'echo "Building commit: $(git rev-parse --short HEAD)"'
            }
        }

        stage('Test') {
            agent {
                // Запускаем тесты в изолированном контейнере Node.js
                docker { image 'node:18-alpine' }
            }
            steps {
                sh 'node test.js'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t ${APP_NAME}:${IMAGE_TAG} -t ${APP_NAME}:latest .'
                sh 'docker images | grep ${APP_NAME}'
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub',
                    usernameVariable: 'DH_USER',
                    passwordVariable: 'DH_PASS'
                )]) {
                    // set +x скрывает команды с паролем в логах
                    sh '''
                        set +x
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                    '''
                    sh 'docker tag ${APP_NAME}:${IMAGE_TAG} $DH_USER/${APP_NAME}:${IMAGE_TAG}'
                    sh 'docker push $DH_USER/${APP_NAME}:${IMAGE_TAG}'
                }
            }
        }

        stage('Deploy (Emulation)') {
            when {
                expression { params.DEPLOY_ENV == 'staging' }
            }
            steps {
                echo "🚀 Deploying ${APP_NAME}:${IMAGE_TAG} to STAGING..."
                sh 'docker rm -f my-app-test || true'
                sh 'docker run -d --name my-app-test ${APP_NAME}:${IMAGE_TAG}'
                sh 'docker logs my-app-test'
                sh 'docker rm -f my-app-test'
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline ${env.IMAGE_TAG} SUCCEEDED. Ready for ${params.DEPLOY_ENV}."
            // Здесь можно вызывать уведомление в Telegram/Slack
        }
        failure {
            echo "❌ Pipeline ${env.IMAGE_TAG} FAILED. Check logs!"
        }
        always {
            // Очищаем за собой локальные образы, чтобы не забивать диск Jenkins-а
            sh 'docker rmi ${APP_NAME}:${IMAGE_TAG} || true'
            sh 'docker rmi ${APP_NAME}:latest || true'
        }
    }
}