pipeline {
    agent any

    options {
        timeout(time: 15, unit: 'MINUTES')
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '15'))
    }

    parameters {
        string(name: 'VERSION_A_DEPLOYER', defaultValue: '',
               description: 'Laisser vide pour construire une nouvelle version. Sinon : numéro de version existante à redéployer (rollback).')
        booleanParam(name: 'DEPLOYER_PROD', defaultValue: false,
                     description: 'Promouvoir la version en production après la recette')
    }

    environment {
        REGISTRY   = 'localhost:5000'
        IMAGE_NAME = 'demo-app'
    }

    stages {
        stage('Préparation') {
            steps {
                script {
                    def demande = (params.VERSION_A_DEPLOYER ?: '').trim()
                    env.BUILD_NEW = demande ? 'false' : 'true'
                    env.TAG       = demande ?: env.BUILD_NUMBER
                    env.IMAGE     = "${env.REGISTRY}/${env.IMAGE_NAME}:${env.TAG}"
                }
                echo "Image ciblée : ${env.IMAGE} (nouvelle construction : ${env.BUILD_NEW})"
                sh 'docker version --format "Serveur Docker : {{.Server.Version}}"'
            }
        }

        stage('Build & push') {
            when {
                environment name: 'BUILD_NEW', value: 'true'
            }
            steps {
                sh '''
                    docker build --build-arg APP_VERSION=${TAG} -t ${IMAGE} .
                    docker push ${IMAGE}
                '''
            }
        }
        stage('Déploiement recette') {
            steps {
                sh 'sh deploy.sh recette 8081 ${IMAGE}'
                sh 'sh smoke_test.sh http://demo-app-recette:8000 ${TAG}'
            }
        }
            stage('Validation production') {
            when {
                expression { params.DEPLOYER_PROD }
            }
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    input message: "Déployer la version ${env.TAG} en production ?",
                          ok: 'Déployer',
                          submitter: 'admin'
                }
            }
        }

        stage('Déploiement production') {
            when {
                expression { params.DEPLOYER_PROD }
            }
            steps {
                sh 'sh deploy.sh production 8082 ${IMAGE}'
                sh 'sh smoke_test.sh http://demo-app-production:8000 ${TAG}'
            }
        }
    }
}
