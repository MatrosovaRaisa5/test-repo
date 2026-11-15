pipeline {
    agent any

    options {
        timeout(time: 10, unit: 'MINUTES')
    }

    stages {
        stage('Secret text lifecycle') {
            steps {
                withCredentials([string(credentialsId: 'my-api-token', variable: 'API_TOKEN')]) {
                    // 1. Длина — безопасно, не раскрывает значение
                    sh 'echo "Token length: ${#API_TOKEN}"'

                    // 2. Прямой вывод — должен быть замаскирован
                    sh 'echo "Direct: $API_TOKEN"'

                    // 3. Проверяем, что переменная есть в окружении блока
                    sh 'printenv | grep API_TOKEN || echo "not in env"'
                }

                // 4. После блока переменной НЕ должно быть
                sh 'echo "Outside: ${API_TOKEN:-NOT_SET}"'
            }
        }

        stage('Secret file') {
            steps {
                withCredentials([file(credentialsId: 'app-config', variable: 'CONFIG_FILE')]) {
                    // Выводим содержимое — Jenkins должен маскировать строки,
                    // совпадающие с содержимым файла
                    sh 'cat "$CONFIG_FILE"'
                }
            }
        }
    }
}