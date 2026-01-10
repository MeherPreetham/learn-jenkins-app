pipeline{
    agent any
    environment{
        AWS_S3_BUCKET = 'learn-jenkins-271220250257'
        AWS_DEFAULT_REGION = 'ap-south-1'
        AWS_ECS_CLUSTER = 'LearnJenkinsApp-Cluster-Prod-08012026'
    }

    stages {

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

        stage('Build Docker image') {
            agent{
                docker{
                    image 'amazon/aws-cli:2.32.23'
                    args "-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=''"
                    reuseNode true
                }
            }
            steps {
                sh '''
                    amazon-linux-extras install docker
                    docker build -t my-jenkinsapp .'
                '''
            }
        }

        stage ('Deploy to AWS'){
            agent{
                docker{
                    image 'amazon/aws-cli:2.32.23'
                    args "-u root --entrypoint=''"
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
                        yum install jq -y
                        LATEST_TD_REVISION=$(aws ecs register-task-definition --cli-input-json file://aws/task-definition-prod.json | jq '.taskDefinition.revision')
                        echo $LATEST_TD_REVISION
                        aws ecs update-service --cluster $AWS_ECS_CLUSTER --service LearnJenkinsApp-TaskDefinition-Prod-service --task-definition LearnJenkinsApp-TaskDefinition-Prod:$LATEST_TD_REVISION
                        aws ecs wait services-stable --cluster $AWS_ECS_CLUSTER --services LearnJenkinsApp-TaskDefinition-Prod-service
                        echo "finished deploying"
                        '''
                }
            }
        }
    }
}
