pipeline{
    agent any
    environment{
        NETLIFY_SITE_ID = '83427a98-300e-4097-929a-e2f65a5eef54'
        NETLIFY_AUTH_TOKEN = credentials('Netlify-token')
    }
    stages{
        stage ('build') {
            agent{
                docker{
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps{
                sh '''
                    npm install netlify-cli 
                    node_modules/.bin/netlify --version
                    echo "Site ID = $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --prod
                '''
            }
        }

        stage ('run tests'){
            parallel{
                    stage ('unit-test') {
                        agent{
                            docker{
                                image 'node:18-alpine'
                                reuseNode true
                            }
                        }
                        steps{
                            sh '''
                                #test -f build/index.html
                                npm test
                            '''
                        }
                        post {
                            always{
                                junit 'junit-test-results/junit.xml'
                            }
                        }
                    }
                    stage ('E2E') {
                        agent{
                            docker{
                                image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                                reuseNode true
                            }
                        }
                        steps {
                            sh '''
                                    npm install serve
                                    node_modules/.bin/serve -s build &
                                    sleep 10
                                    npx playwright test --reporter=html
                            '''
                        }
                        post {
                            always{
                                publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                            }
                        }
                    }
            }
        }
    }
}
