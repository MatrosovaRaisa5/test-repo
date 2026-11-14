pipeline {
    // ГДЕ выполняем: на любом доступном агенте
    agent any

    options {
        // Защита от зависаний: максимум 10 минут
        timeout(time: 10, unit: 'MINUTES')
        // Храним только 10 последних сборок
        buildDiscarder(logRotator(numToKeepStr: '10'))
        // Не запускаем две сборки одновременно
        disableConcurrentBuilds()
    }

    parameters {
        // Входные данные, которые можно менять при запуске
        choice(name: 'TARGET_ENV', choices: ['staging', 'prod'], description: 'Куда деплоим')
        string(name: 'APP_VERSION', defaultValue: '1.0.0', description: 'Версия приложения')
        booleanParam(name: 'RUN_LINT', defaultValue: true, description: 'Запускать линтер?')
    }

    environment {
        // Переменные, вычисляемые на основе параметров и встроенных переменных
        APP_NAME = 'my-app'
        BUILD_LABEL = "${params.APP_VERSION}-${BUILD_NUMBER}"
    }

    stages {
        stage('Prepare') {
            steps {
                echo "Building ${env.APP_NAME} version ${env.BUILD_LABEL}"
                echo "Target env: ${params.TARGET_ENV}"
                sh 'echo "Working dir: $(pwd)"'
                sh 'ls -la'
            }
        }

        stage('Parallel checks') {
            // ЗАПУСКАЕМ ДВА ЭТАПА ОДНОВРЕМЕННО
            parallel {
                stage('Test') {
                    steps {
                        sh 'echo "Running tests..."'
                        sh 'sleep 2' // Имитация работы
                        sh 'echo "Tests passed"'
                    }
                }
                stage('Lint') {
                    // УСЛОВНОЕ ВЫПОЛНЕНИЕ: только если RUN_LINT == true
                    when {
                        expression { return params.RUN_LINT }
                    }
                    steps {
                        sh 'echo "Running linter..."'
                        sh 'sleep 1'
                        sh 'echo "Lint OK"'
                    }
                }
            }
        }

        stage('Package') {
            steps {
                sh 'echo "Packaging ${APP_NAME}:${BUILD_LABEL}..."'
                sh 'echo "artefact-content" > build.txt'
                // СОХРАНЯЕМ АРТЕФАКТ сборки
                archiveArtifacts artifacts: 'build.txt', fingerprint: true
            }
        }

        stage('Deploy') {
            // УСЛОВНОЕ ВЫПОЛНЕНИЕ: только для staging
            when {
                expression { return params.TARGET_ENV == 'staging' }
            }
            steps {
                sh 'echo "Deploying to staging..."'
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline ${env.BUILD_LABEL} succeeded!"
        }
        failure {
            echo "❌ Pipeline ${env.BUILD_LABEL} failed!"
        }
        cleanup {
            echo "Cleaning up..."
            // cleanWs() раскомментируем в День 4
        }
    }
}