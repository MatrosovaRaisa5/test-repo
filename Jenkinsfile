pipeline {
	agent any

	options {
		timeout(time: 10, unit: "MINUTES")
		buildDiscarder(logRotator(numToKeepStr: '10'))
		disableConcurrentBuilds()
	}

	parameters {
		choice(name: 'TARGET_ENV', choices: ['staging', 'prod'], description: 'Куда деплоим')
		string(name: 'APP_VERSION', defaultValue: '1.0.0', description: 'Версия приложения')
		booleanParam(name: 'RUN_LINT', defaultValue: true, description='Нужно ли запускать линтер')
	}

	environment {
		APP_NAME = 'my-first-app'
		BUILD_LABEL = '${params.APP_VERSION}-${BUILD_NUMBER}'
	}

	stages {
		stage('Prepare') {
			steps {
				echo "Building ${env.APP_NAME} version ${env.BUILD_LABEL}"
				echo "Target env: ${params.TARGET_ENV}"
				sh 'echo "Current dir: $(pwd)"'
				sh 'echo "Files:"'
				sh 'ls -la'

			}
		}

		stage('Parallel checks') {
			parallel {
				stage('Test') {
					steps {
						sh 'echo "Check the tests"'
						sh 'sleep 5'
						sh 'echo "Tests passed"'
					}
				}

				stage('Linting') {
					when {
						expression { return params.RUN_LINT }
					}
					steps {
						sh 'echo "Running linters"'
						sh 'sleep 3'
						sh 'echo "Lint OK"'
					}
				}
			}
		}

		stage('Package') {
			steps {
				sh 'echo "Packaging ${env.APP_NAME}:${env.BUILD_LABEL}"'
				sh 'echo "artefact-content" > build.txt'
				archiveArtifacts artifacts: 'build.txt', fingerprint: true
			}
		}

		stage('Deploy') {
			when {
				expression { return params.TARGET_ENV == 'staging' }
			}
			steps {
				sh 'echo "Deploy to staging..."'
			}
		}
	}

	post {
		success {
			echo "Pipeline ${env.BUILD_LABEL} succeeded!"
		}
		failure {
			echo "Pipeline ${env.BUILD_LABEL} failed!"
		}
		cleanup {
			echo "lalala"
		}
	}

}