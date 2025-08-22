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

        stage('Terraform Init & Plan') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh 'terraform init'
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Provision Infrastructure') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-credentials',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    dir("${TERRAFORM_DIR}") {
                        // Avoid Groovy interpolation for secrets
                        sh '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }

        stage('Prepare Ansible Inventory') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    script {
                        def publicIp = sh(
                            script: "terraform -chdir=../${TERRAFORM_DIR} output -raw flask_app_public_ip",
                            returnStdout: true
                        ).trim()

                        writeFile file: 'inventory.ini', text: """[web]
${publicIp} ansible_user=ec2-user ansible_python_interpreter=/usr/bin/python3
"""
                        sh 'dos2unix inventory.ini playbook.yml'
                        sh 'cat inventory.ini'
                    }
                }
            }
        }

        stage('Configure & Deploy with Ansible') {
            steps {
                sshagent(['terraform-key']) {
                    dir("${ANSIBLE_DIR}") {
                        sh 'ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yml'
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
                        def result = sh(script: 'curl -sf http://localhost:8777 || true', returnStatus: true)
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


