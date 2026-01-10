pipeline{
    agent any
    environment{
        AWS_S3_BUCKET = 'learn-jenkins-271220250257'
        AWS_DEFAULT_REGION = 'ap-south-1'
        AWS_ECS_CLUSTER = 'LearnJenkinsApp-Cluster-Prod-08012026'
        AWS_ECS_SERVICE = 'LearnJenkinsApp-TaskDefinition-Prod-service'
        AWS_ECS_TD = 'LearnJenkinsApp-TaskDefinition-Prod'
    }

    stages {

        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
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
                    image 'amazon/aws-cli'
                    reuseNode true
                    args "-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=''"
                }
            }
            steps {
                sh '''
                    yum update -y
                    yum install docker -y
                    docker build -t my-jenkinsapp .
                '''
            }
        }

        stage ('Deploy to AWS'){
            agent{
                docker{
                    image 'amazon/aws-cli'
                    args "-u root --entrypoint=''"
                    reuseNode true
                }
            }
             steps{
                withCredentials([usernamePassword(credentialsId: 'aws-s3', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        yum install jq -y
                        LATEST_TD_REVISION=$(aws ecs register-task-definition --cli-input-json file://aws/task-definition-prod.json | jq '.taskDefinition.revision')
                        echo $LATEST_TD_REVISION
                        aws ecs update-service --cluster $AWS_ECS_CLUSTER --service $AWS_ECS_SERVICE --task-definition $AWS_ECS_TD:$LATEST_TD_REVISION
                        aws ecs wait services-stable --cluster $AWS_ECS_CLUSTER --services $AWS_ECS_SERVICE
                        echo "finished deploying"
                        '''
                }
            }
        }
    }
}
