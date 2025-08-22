pipeline {
    agent any

    environment {
        APP_DIR = 'app'
        TERRAFORM_DIR = 'terraform'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-credentials', 
                    usernameVariable: 'AWS_ACCESS_KEY_ID', 
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    dir(TERRAFORM_DIR) {
                        sh '''
                            terraform init
                            terraform plan -out=tfplan \
                                -var="aws_access_key=$AWS_ACCESS_KEY_ID" \
                                -var="aws_secret_key=$AWS_SECRET_ACCESS_KEY" \
                                -var="key_name=terraform-generated-key"
                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }

        stage('Prepare Ansible Inventory') {
            steps {
                echo 'Preparing Ansible inventory...'
            }
        }

        stage('Configure & Deploy with Ansible') {
            steps {
                echo 'Configuring and deploying application with Ansible...'
            }
        }

        stage('Build & Run Docker') {
            steps {
                dir(APP_DIR) {
                    sh 'docker compose up -d'
                }
            }
        }

        stage('Verify App & Containers') {
            steps {
                sh 'docker ps'
            }
        }

        stage('Run Selenium Tests') {
            steps {
                echo 'Running Selenium tests...'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
            dir(APP_DIR) {
                sh 'docker compose up -d'
            }
        }
    }
}


