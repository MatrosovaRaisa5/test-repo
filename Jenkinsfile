@Library('my-shared-lib@v1.0.2') _

pipeline {
    agent any

    options {
        timeout(time: 20, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '15', artifactNumToKeepStr: '5'))
        disableConcurrentBuilds()
    }

    parameters {
        string(name: 'APP_VERSION', defaultValue: '1.0.0', description: 'Version')
    }

    environment {
        APP_NAME = 'my-app'
        IMAGE_TAG = "${params.APP_VERSION}-${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
		echo 'Это сборка из ветки feature/test'
                cleanWs()
                checkout scm
                sh 'git rev-parse --short HEAD'
            }
        }

        stage('Docker Build') {
            steps {
                // ВЫЗОВ ШАГА ИЗ SHARED LIBRARY
                buildDockerImage(
                    image: "${APP_NAME}",
                    tag: "${IMAGE_TAG}"
                )
            }
        }

        stage('Notify') {
            steps {
                // ВТОРОЙ ШАГ ИЗ БИБЛИОТЕКИ
                notifySlack(
                    message: "Build ${IMAGE_TAG} succeeded!",
                    channel: '#builds'
                )
            }
        }

        stage('Run on Specific Agent') {
            agent { label 'my-build-agent' } 
            
            steps {
                echo 'Этот этап выполняется на выделенном агенте docker-agent-1!'
                sh 'hostname' 
            }
        }
    }

    post {
        failure {
            notifySlack(
                message: "Build ${IMAGE_TAG} failed!",
                channel: '#builds'
            )
        }
    }
}
