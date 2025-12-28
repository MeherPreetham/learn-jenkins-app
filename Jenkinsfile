pipeline{
    agent any
    environment{
        AWS_S3_BUCKET = 'learn-jenkins-271220250257'
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

        stage ('Uploading Website to AWS S3'){
                    agent{
                        docker{
                            image 'amazon/aws-cli:2.32.23'
                            args "--entrypoint=''"
                        }
                    }
                    environment{
                        AWS_S3_BUCKET = 'learn-jenkins-271220250257'
                    }
                    steps{
                        withCredentials([usernamePassword(credentialsId: 'aws-s3', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                            sh '''
                                aws --version
                                aws s3 sync build/ s3://$AWS_S3_BUCKET --delete
                                aws s3 ls s3://$AWS_S3_BUCKET
                                '''
                            }
                        }
                    }

        stage('Tests') {
            parallel {
                stage('Unit tests') {
                    agent {
                        docker {
                            image 'node:18'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            #test -f build/index.html
                            npm test
                        '''
                    }
                    post {
                        always {
                            junit 'junit-test-results/junit.xml'
                        }
                    }
                }

                stage('E2E') {
                    agent {
                        docker {
                            image 'my-playwright'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            serve -s build &
                            sleep 10
                            npx playwright test  --reporter=html
                        '''
                    }

                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright E2E', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }
    }
}
