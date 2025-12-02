pipeline{
     agent{
            docker{
                image 'node:18-alpine'
                reuseNode true
            }
        }
    stages{
        stage('Build'){
            steps{
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                '''
            }
        }
        stage ('test') {
            steps{
                sh '''
                    test learn-jenkins-app/build/index.html
                    npm test
                '''
            }
        }
    }
}
