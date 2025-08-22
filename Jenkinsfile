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
                    sh """
                        terraform -chdir=terraform output -raw public_ip > public_ip.txt
                        terraform -chdir=terraform output -raw terraform_key_pem > terraform-key.pem
                        chmod 600 terraform-key.pem
        
                        cat > inventory_generated.yml <<EOL
        all:
          hosts:
            \$(cat public_ip.txt):
              ansible_user: ec2-user
              ansible_ssh_private_key_file: \$(pwd)/terraform-key.pem
        EOL
                    """
        }
    }
}

                    def publicIp = sh(
                        script: "terraform -chdir=${TERRAFORM_DIR} output -raw public_ip",
                        returnStdout: true
                    ).trim()
                    
                    // Get private key directly from Terraform output, remove carriage returns
                    def privateKey = sh(
                        script: "terraform -chdir=${TERRAFORM_DIR} output -raw terraform_key_pem | tr -d '\\r'",
                        returnStdout: true
                    ).trim()

                    writeFile file: 'private_key.pem', text: privateKey
                    sh 'chmod 600 private_key.pem'

                    def inventory = """
web:
  hosts:
    ${publicIp}:
      ansible_user: ec2-user
      ansible_ssh_private_key_file: /var/lib/jenkins/workspace/e-commerce/terraform/terraform-key.pem
      ansible_python_interpreter: /usr/bin/python3
"""
                    writeFile file: 'inventory_generated.yml', text: inventory
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
    }

    post {
        always {
            echo 'Ensuring all containers are running'
            sh 'docker compose up -d --remove-orphans'
        }
    }
}

