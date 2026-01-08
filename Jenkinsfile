pipeline{
    agent any
    environment{
        AWS_S3_BUCKET = 'learn-jenkins-271220250257'
        AWS_DEFAULT_REGION = 'ap-south-1'
    }

    stages {

        stage ('Deploy to AWS'){
            agent{
                docker{
                    image 'amazon/aws-cli:2.32.23'
                    args "--entrypoint=''"
                    reuseNode true
                }
            }
            environment{
                AWS_S3_BUCKET = 'learn-jenkins-271220250257'
            }
            steps{
                withCredentials([usernamePassword(credentialsId: 'aws-s3', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        aws ecs register-task-definition --cli-input-json file://aws/task-definition-prod.json
                        '''
                }
            }
        }
        stage('Build') {
            agent {
                docker {
                    image 'node:18'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm ci
                    npm run build
                '''
            }
        }
    }
}
