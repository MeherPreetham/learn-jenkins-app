pipeline{
    agent any
    stages{
        stage('Hello world'){
            agent{
                docker{
                    image 'node:18-alpine'
                }
            }
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
    }
}
