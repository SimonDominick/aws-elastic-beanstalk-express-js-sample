pipeline {
  agent any

  stages {

    stage('Checkout') {
        steps {
            echo 'Checking out source code...'
            checkout scm
        }
    }

    stage('Install Dependencies ') {
      steps {
        sh '''
          docker run --rm -u 0:0 -v "$PWD":/app -w /app node:16 bash -lc '
            set -e
            node -v && npm -v
            npm install --save
          '
        '''
      }
    }

    stage('Run Unit Tests') {
      steps {
        sh '''
          docker run --rm -u 0:0 -v "$PWD":/app -w /app node:16 bash -lc '
            set -e
            if npm run | grep -qE "^\\s*test\\s"; then
              npm test
            else
              echo "No test script; skipping."
            fi
          '
        '''
      }
    }

    stage('Security scan') {
      steps {
        script {
          withCredentials([string(credentialsId: 'snyk-api-token', variable: 'SNYK_TOKEN')]) {
            sh '''
                docker run --rm -u 0:0 -e SNYK_TOKEN="$SNYK_TOKEN" \
                  -v "$PWD":/app -w /app node:20-bookworm bash -lc "
                    set -e
                    npm i -g snyk
                    snyk auth \\"$SNYK_TOKEN\\"
                    snyk test --severity-threshold=high
                  "
            '''
          }
        }
      }
    }

    stage('Build Docker image') {
      steps {
        sh 'docker version'
        sh 'docker build -t simondominick/express-app  .'
      }
    }

    stage('Push image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials-id',
                                          usernameVariable: 'DOCKER_USER',
                                          passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push simondominick/express-app
          '''
        }
      }
    }
  }

  post {
      success {
          echo 'Pipeline executed successfully!'
      }
      failure {
          echo 'Pipeline failed. Please check the logs.'
      }

      always {
        recordIssues tools: [errorProne()]
      }
  }
}
