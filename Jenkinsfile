pipeline {
    agent any

    environment {
        TERRAFORM_DIR = "terraform"
        PEM_CREDENTIALS_ID = "aws-pem-key"   /* Jenkins credential ID for PEM file */
        AWS_CREDENTIALS_ID = "aws-credentials"
        BRANCH_NAME = "main"
        REGION = "us-west-2"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: "*/${BRANCH_NAME}"]],
                    userRemoteConfigs: [[
                        url: 'https://github.com/AdeleyeAdeyemi/e-commerce',
                        credentialsId: "${AWS_CREDENTIALS_ID}"
                    ]]
                ])
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: "${AWS_CREDENTIALS_ID}",
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    dir("${TERRAFORM_DIR}") {
                        sh '''
                            terraform init
                            terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Prepare Ansible Inventory') {
            steps {
                withCredentials([file(credentialsId: "${PEM_CREDENTIALS_ID}", variable: 'PEM_FILE')]) {
                    script {
                        // Get Terraform outputs
                        def publicIp = sh(
                            script: "terraform -chdir=${TERRAFORM_DIR} output -raw public_ip",
                            returnStdout: true
                        ).trim()

                        sh "chmod 600 ${PEM_FILE}"

                        // Create Ansible inventory
                        def inventory = """
all:
  hosts:
    ${publicIp}:
      ansible_user: ec2-user
      ansible_ssh_private_key_file: ${PEM_FILE}
      ansible_python_interpreter: /usr/bin/python3
"""
                        writeFile file: 'inventory_generated.yml', text: inventory
                    }
                }
            }
        }

        stage('Configure & Deploy with Ansible') {
            steps {
                sh 'ansible-playbook -i inventory_generated.yml ansible/playbook.yml'
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
                sh 'sleep 30'
            }
        }

        stage('Run Selenium Tests') {
            steps {
                sh '''
                    python3 -m venv venv --copies
                    ./venv/bin/pip install --upgrade pip --break-system-packages
                    ./venv/bin/pip install -r requirements.txt --break-system-packages
                    ./venv/bin/pip install pytest selenium --break-system-packages
                    ./venv/bin/pytest tests/selenium
                '''
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







