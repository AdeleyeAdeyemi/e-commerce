
pipeline {
    agent any

    environment {
        TF_VAR_region = 'eu-west-2'   // Terraform region
        TERRAFORM_DIR = 'terraform'
        ANSIBLE_DIR = 'ansible'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/AdeleyeAdeyemi/e-commerce'
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Provision Infrastructure') {
            steps {
                // Inject AWS credentials and Terraform key from Jenkins
                withCredentials([
                    usernamePassword(credentialsId: 'aws-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY'),
                    file(credentialsId: 'terraform-key', variable: 'TF_KEY_FILE')
                ]) {
                    dir("${TERRAFORM_DIR}") {
                        sh '''
                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

                            terraform apply -auto-approve \
                                -var="aws_access_key=${AWS_ACCESS_KEY_ID}" \
                                -var="aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
                                -var="key_name=terraform-generated-key" \
                                -var="private_key_path=${TF_KEY_FILE}"
                        '''
                        script {
                            env.NEW_PUBLIC_IP = sh(
                                script: 'terraform output -raw public_ip',
                                returnStdout: true
                            ).trim()
                        }
                    }
                }
            }
        }

        stage('Prepare Ansible Inventory') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh '''
                        mkdir -p ${ANSIBLE_DIR}

                        echo "[web]
${NEW_PUBLIC_IP} ansible_user=ec2-user ansible_ssh_private_key_file=${TF_KEY_FILE} ansible_python_interpreter=/usr/bin/python3" > inventory.ini

                        dos2unix inventory.ini
                        dos2unix playbook.yml
                    '''
                }
            }
        }

        stage('Wait for SSH') {
            steps {
                sshagent(credentials: ['terraform-key']) {
                    script {
                        echo "Waiting for SSH on ${env.NEW_PUBLIC_IP}..."
                        retry(12) {
                            sh """
                                nc -zv ${env.NEW_PUBLIC_IP} 22 || (echo 'SSH not ready, retrying...' && exit 1)
                                ssh -o StrictHostKeyChecking=no -i ${TF_KEY_FILE} ec2-user@${env.NEW_PUBLIC_IP} "echo connected"
                            """
                            sleep 10
                        }
                    }
                }
            }
        }

        stage('Configure & Deploy with Ansible') {
            steps {
                sshagent(credentials: ['terraform-key']) {
                    dir("${ANSIBLE_DIR}") {
                        sh 'ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yml'
                    }
                }
            }
        }

        stage('Build & Run App with Docker') {
            steps {
                sh 'chmod +x build.sh && ./build.sh'

                script {
                    def buildStatus = sh(script: 'docker compose build --no-cache', returnStatus: true)
                    if (buildStatus != 0) {
                        sh 'docker compose logs || true'
                        error 'Docker Compose build failed'
                    }

                    def upStatus = sh(script: 'docker compose up -d', returnStatus: true)
                    if (upStatus != 0) {
                        sh 'docker compose logs || true'
                        error 'Docker Compose up failed'
                    }
                }
            }
        }

        stage('Verify App & Docker') {
            steps {
                sh """
                    docker ps
                    docker logs \$(docker ps -q --filter "name=ecommerce-app") || true
                    docker exec \$(docker ps -q --filter "name=ecommerce-app") pip list || true
                """
            }
        }

        stage('Wait for App to be Ready') {
            steps {
                script {
                    def maxRetries = 20
                    def waitSeconds = 6
                    def ready = false

                    for (int i = 0; i < maxRetries; i++) {
                        if (sh(script: "curl -sf http://${env.NEW_PUBLIC_IP}:8777 || true", returnStatus: true) == 0) {
                            echo "App is ready"
                            ready = true
                            break
                        }
                        echo "App not ready, waiting ${waitSeconds}s..."
                        sleep(waitSeconds)
                    }

                    if (!ready) {
                        sh 'docker logs $(docker ps -q --filter "name=ecommerce-app") || true'
                        error "App did not become ready in time"
                    }
                }
            }
        }

        stage('Run Selenium Tests') {
            steps {
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip selenium
                    # Add your Selenium test commands here
                '''
            }
        }
    }

    post {
        always {
            echo "Ensuring all containers are up"
            sh 'docker compose up -d || true'
        }
    }
}









