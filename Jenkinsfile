pipeline {
    agent any

    environment {
        TERRAFORM_DIR = "terraform"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/AdeleyeAdeyemi/e-commerce',
                        credentialsId: 'aws-credentials'
                    ]]
                ])
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-credentials',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    dir("${TERRAFORM_DIR}") {
                        sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

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
        script {
            def publicIp = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()
            def privateKey = sh(script: "terraform output -raw private_key_pem", returnStdout: true).trim()

            // Save private key
            writeFile file: 'private_key.pem', text: privateKey
            sh 'chmod 600 private_key.pem'

            // Generate inventory
            writeFile file: 'inventory_generated.ini', text: """
[flask_app]
${publicIp} ansible_user=ec2-user ansible_ssh_private_key_file=private_key.pem
"""
        }
    }
}
        stage('Configure & Deploy with Ansible') {
            steps {
                sh 'ansible-playbook -i inventory/hosts deploy_app.yml'
            }
        }

        stage('Build & Run Docker') {
            steps {
                sh 'docker compose up -d --remove-orphans'
            }
        }

        stage('Verify App & Containers') {
            steps {
                sh 'docker ps'
            }
        }

        stage('Wait for App Ready') {
            steps {
                sh 'sleep 30'  // simple wait, can replace with health check
            }
        }

        stage('Run Selenium Tests') {
            steps {
                sh 'pytest tests/selenium'
            }
        }
    }

    post {
        always {
            echo 'Ensuring all containers are running'
            sh 'docker compose up -d --remove-orphans'
        }
    }
}


