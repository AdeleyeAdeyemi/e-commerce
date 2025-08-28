pipeline {
    agent any

    environment {
        TERRAFORM_DIR = "terraform"
        PEM_CREDENTIALS_ID = "aws-pem-key"   // Jenkins credential ID for PEM file
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
                script {
                    // Get Terraform outputs
                    def publicIp = sh(
                        script: "terraform -chdir=${TERRAFORM_DIR} output -raw public_ip",
                        returnStdout: true
                    ).trim()
        
                    // Use the Terraform-generated PEM file
                    def pemFile = "${TERRAFORM_DIR}/jenkins-key.pem"
                    sh "chmod 600 ${pemFile}"
        
                    // Create Ansible inventory
                    def inventory = """
all:
  hosts:
    ${publicIp}:
      ansible_user: ec2-user
      ansible_ssh_private_key_file: terraform/jenkins-key.pem
      ansible_python_interpreter: /usr/bin/python3
      ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' 
      
"""
                    writeFile file: 'inventory_generated.yml', text: inventory
                    echo "Ansible inventory created:\n${inventory}"
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
                    if [ ! -d "venv" ]; then
                        python3 -m venv --copies --upgrade-deps venv
                    fi

                    ./venv/bin/python3 -m pip install --upgrade "pip<24" setuptools wheel
                    ./venv/bin/python3 -m pip install -r requirements.txt pytest selenium 
                    ./venv/bin/python3 -m pytest tests/selenium --maxfail=1 --disable-warnings -q
                    
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

















