pipeline{
    agent any
    environment{
        NETLIFY_SITE_ID = '83427a98-300e-4097-929a-e2f65a5eef54'
        NETLIFY_AUTH_TOKEN = credentials('Netlify-token')
    }

    stages {

        stage ('AWS'){
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
                        aws s3 ls
                        echo "Hello to S3!" > index.html
                        aws s3 cp file.txt s3://$AWS_S3_BUCKET/index.html
                        aws s3 ls s3://$AWS_S3_BUCKET
                        aws s3 cp s3://$AWS_S3_BUCKET/index.html -

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

        stage('Deploy staging and E2E') {
                    agent {
                        docker {
                            image 'my-playwright'
                            reuseNode true
                        }
                    }

                    environment {
                        CI_ENVIRONMENT_URL = 'STAGING_URL_TO_BE_SET'
                    }

                    steps {
                        sh '''
                            netlify --version
                            echo "Site ID: $NETLIFY_SITE_ID"
                            netlify status
                            netlify deploy --dir=build --json > deploy-output.json
                            CI_ENVIRONMENT_URL=$(jq -r '.deploy_url' deploy-output.json)
                            npx playwright test  --reporter=html
                        '''
                    }

                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Staging E2E', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
        
        stage('Approval'){
            steps{
                timeout(time: 15, unit: 'MINUTES') {
                    input message: 'Approve deployment to production?', ok: 'Deploy'
                }
            }
        }

        stage('Deploy prod and E2E') {
            agent {
                docker {
                    image 'my-playwright'
                    reuseNode true
                }
            }

            environment {
                CI_ENVIRONMENT_URL = 'https://elaborate-dolphin-0acdce.netlify.app'
            }

            steps {
                sh '''
                    node --version
                    netlify --version
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                    netlify status
                    netlify deploy --dir=build --prod
                    npx playwright test  --reporter=html
                '''
            }

            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Prod E2E', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }
    }
}
