pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        
        stage('Install Dependencies') {

            agent { docker { image 'node:16'; args '-u root:root' } }
            steps {
                echo 'Installing npm packages...'
                sh 'npm install --save'
            }
        }

        stage('Run Unit Tests') {
            agent { docker { image 'node:16'; args '-u root:root' } }
            steps {
                echo 'Running start...'
                sh 'npm test'
            }
        }


        stage('Security Scan') {
            agent { docker { image 'node:20-bookworm'; args '-u root:root' } }
            steps {
                withCredentials([string(credentialsId: 'snyk-api-token', variable: 'SNYK_TOKEN')]) {
                    sh '''
                      npm install -g snyk
                      snyk auth $SNYK_TOKEN
                      snyk test --severity-threshold=high
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t simondominick/express-app ."
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials-id',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push simondominick/express-app 
                    '''
                }
            }
        }
    }

}


