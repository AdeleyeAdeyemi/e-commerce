pipeline {
    agent any

    environment {
        TF_VAR_region = 'eu-west-2'
        TERRAFORM_DIR = 'terraform'
        ANSIBLE_DIR = 'ansible'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/AdeleyeAdeyemi/e-commerce'
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
                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

                            terraform init
                            terraform apply -auto-approve \
                                -var="aws_access_key=${AWS_ACCESS_KEY_ID}" \
                                -var="aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
                                -var="key_name=terraform-generated-key"
                        """
                    }
                }
            }
        }

        stage('Fetch Terraform Outputs') {
            steps {
                script {
                    // Get the public IP of the EC2 instance
                    env.PUBLIC_IP = sh(
                        script: "terraform -chdir=${TERRAFORM_DIR} output -raw public_ip",
                        returnStdout: true
                    ).trim()

                    // Get private key PEM content (do NOT write to disk)
                    env.PRIVATE_KEY_PEM = sh(
                        script: "terraform -chdir=${TERRAFORM_DIR} output -raw private_key_pem",
                        returnStdout: true
                    ).trim()
                }
            }
        }

        stage('Prepare Ansible Inventory') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    writeFile file: 'inventory.ini', text: """[web]
${env.PUBLIC_IP} ansible_user=ec2-user ansible_python_interpreter=/usr/bin/python3
"""
                    sh 'dos2unix inventory.ini playbook.yml'
                    sh 'cat inventory.ini'
                }
            }
        }

        stage('Configure & Deploy with Ansible') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    // Use in-memory private key with ssh-agent
                    withEnv(["PRIVATE_KEY_FILE=${env.WORKSPACE}/temp_ssh_key"]) {
                        writeFile file: env.PRIVATE_KEY_FILE, text: env.PRIVATE_KEY_PEM
                        sh 'chmod 600 $PRIVATE_KEY_FILE'

                        sshagent([env.PRIVATE_KEY_FILE]) {
                            sh 'ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yml'
                        }

                        // Remove ephemeral key
                        sh 'rm -f $PRIVATE_KEY_FILE'
                    }
                }
            }
        }

        stage('Build & Run Docker') {
            steps {
                sh 'chmod +x build.sh && ./build.sh'
                script {
                    def buildResult = sh(script: 'docker compose build --no-cache', returnStatus: true)
                    if (buildResult != 0) {
                        sh 'docker compose logs || true'
                        error 'Docker Compose build failed'
                    }

                    def upResult = sh(script: 'docker compose up -d', returnStatus: true)
                    if (upResult != 0) {
                        sh 'docker compose logs || true'
                        error 'Failed to start containers'
                    }
                }
            }
        }

        stage('Verify App & Containers') {
            steps {
                sh '''
                    echo "Running containers:"
                    docker ps

                    echo "Flask container logs:"
                    docker logs $(docker ps -q --filter "name=ecommerce-app") || true

                    echo "Python packages in Flask container:"
                    docker exec $(docker ps -q --filter "name=ecommerce-app") pip list || true
                '''
            }
        }

        stage('Wait for App Ready') {
            steps {
                script {
                    def maxRetries = 20
                    def waitSeconds = 6
                    def ready = false

                    for (int i = 0; i < maxRetries; i++) {
                        def result = sh(script: "curl -sf http://${env.PUBLIC_IP}:8777 || true", returnStatus: true)
                        if (result == 0) {
                            echo "App is ready"
                            ready = true
                            break
                        } else {
                            echo "App not ready, waiting ${waitSeconds}s..."
                            sleep(waitSeconds)
                        }
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
                    # Add Selenium test commands here
                '''
            }
        }
    }

    post {
        always {
            echo "Ensuring all containers are running"
            sh 'docker compose up -d || true'
        }
    }
}


