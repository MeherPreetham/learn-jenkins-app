pipeline {
    agent any

    environment{
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        AWS_S3_BUCKET = 'learn-jenkins-271220250257'
        AWS_DEFAULT_REGION = 'ap-south-1'
        AWS_ECS_CLUSTER = 'LearnJenkinsApp-Cluster-Prod-08012026'
        AWS_ECS_SERVICE = 'LearnJenkinsApp-TaskDefinition-Prod-service'
        AWS_ECS_TD = 'LearnJenkinsApp-TaskDefinition-Prod'
        APP_NAME = 'learnjenkinsapp'
        AWS_DOCKER_REGISTRY = '648619529559.dkr.ecr.ap-south-1.amazonaws.com'
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
            agent {
                docker {
                    image 'docker:latest'
                    reuseNode true
                    args '-u root -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }

            steps {
                sh '''
                    docker build -t $AWS_DOCKER_REGISTRY/$APP_NAME:$REACT_APP_VERSION .
                    aws ecr get-login-password | docker login --username AWS --password-stdin $AWS_DOCKER_REGISTRY
                    docker push $AWS_DOCKER_REGISTRY/$APP_NAME:$REACT_APP_VERSION
                '''
            }
        }

        stage('Deploy to AWS') {
            agent {
                docker {
                    image 'my-aws-cli'
                    reuseNode true
                    args "-u root --entrypoint=''"
                }
            }

            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-s3', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
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
