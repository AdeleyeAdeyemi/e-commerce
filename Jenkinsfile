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
                        sh """
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

                            terraform init

                            terraform plan -out=tfplan \\
                                -var="aws_access_key=$AWS_ACCESS_KEY_ID" \\
                                -var="aws_secret_key=$AWS_SECRET_ACCESS_KEY" \\
                                -var="key_name=terraform-generated-key
                            terraform apply -auto-approve tfplan

                        """
                    }
                }
            }
        }

        stage('Prepare Ansible Inventory') {
            steps {
                script {
                    def publicIp = sh(script: "terraform -chdir=${TERRAFORM_DIR} output -raw public_ip", returnStdout: true).trim()
                    def privateKey = sh(script: "terraform -chdir=${TERRAFORM_DIR} output -raw private_key_pem", returnStdout: true).trim()

                    // Save private key
                    writeFile file: 'private_key.pem', text: privateKey
                    sh 'chmod 600 private_key.pem'
                    
                    // ✅ Write correct YAML inventory
                    writeFile file: "inventory_generated.yml", text: """
web:
  hosts:
    ${publicIp}:
      ansible_user: ec2-user
      ansible_ssh_private_key_file: private_key.pem
      ansible_python_interpreter: /usr/bin/python3
"""
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
                    python3 -m venv venv --copies venv
                    ./venv/bin/pip install --upgrade pip --break-system-packages
                    ./venv/bin/pip install -r requirements.txt --break-system-packages
                    ./venv/bin/pip install pytest selenium --break-system-packages
                    ./venv/bin/pytest tests/selenium
                '''
            }
        }

    } // end stages

    post {
        always {
            echo 'Ensuring all containers are running'
            sh 'docker compose up -d --remove-orphans'
        }
    }
}






