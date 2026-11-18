pipeline {
    agent any

    options {
        timeout(time: 15, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '5'))
        disableConcurrentBuilds()
    }

    parameters {
        string(name: 'APP_VERSION', defaultValue: '1.0.0', description: 'Version')
        booleanParam(name: 'PUSH_IMAGE', defaultValue: false, description: 'Push to Docker Hub?')
    }

    environment {
        APP_NAME = 'my-app'
        IMAGE_TAG = "${params.APP_VERSION}-${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git rev-parse --short HEAD'
            }
        }

        stage('Secret lifecycle check') {
            steps {
                withCredentials([string(credentialsId: 'my-api-token', variable: 'API_TOKEN')]) {
                    sh 'echo "Token length: ${#API_TOKEN}"'
                    sh 'echo "Masked: $API_TOKEN"'
                }
                sh 'echo "Outside: ${API_TOKEN:-NOT_SET}"'
            }
        }

        stage('Docker Build') {
            steps {
                sh './scripts/build-docker.sh ${APP_NAME} ${IMAGE_TAG}'
                sh 'docker images | grep ${APP_NAME} || true'
            }
        }

        stage('Docker Push') {
            when {
                expression { return params.PUSH_IMAGE }
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub',
                    usernameVariable: 'DH_USER',
                    passwordVariable: 'DH_PASS'
                )]) {
                    // set +x — чтобы команды не эхо-выводились с секретами
                    sh '''
                        set +x
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                    '''
                    sh 'docker tag ${APP_NAME}:${IMAGE_TAG} $DH_USER/${APP_NAME}:${IMAGE_TAG}'
                    sh 'docker tag ${APP_NAME}:${IMAGE_TAG} $DH_USER/${APP_NAME}:latest'
                    sh 'docker push $DH_USER/${APP_NAME}:${IMAGE_TAG}'
                    sh 'docker push $DH_USER/${APP_NAME}:latest'
                }
            }
        }

        stage('Run container') {
            steps {
                sh 'docker rm -f ${APP_NAME}-test || true'
                sh 'docker run -d --name ${APP_NAME}-test ${APP_NAME}:${IMAGE_TAG}'
                sh 'docker logs ${APP_NAME}-test'
                sh 'docker rm -f ${APP_NAME}-test'
            }
        }
    }

    post {
        cleanup { cleanWs() }
        success { echo "✅ Build ${IMAGE_TAG} succeeded" }
        failure { echo "❌ Build ${IMAGE_TAG} failed" }
        cleanup {
            sh 'docker rmi ${APP_NAME}:latest || true'
        }
    }
}