pipeline {
    agent any

    environment {
        TF_VAR_region = 'eu-west-2'  // Global Terraform variable
        ELK_HOST = 'logstash'         // For Flask app logging
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/AdeleyeAdeyemi/e-commerce'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Remove orphaned SG from state') {
            steps {
                dir('terraform') {
                    sh '''
                        if terraform state list | grep -q aws_security_group.allow_ssh; then
                            echo "Removing orphaned SG from Terraform state..."
                            terraform state rm aws_security_group.allow_ssh || true
                        else
                            echo "No orphaned SG found in Terraform state."
                        fi
                    '''
                }
            }
        }

        stage('Import SG if exists') {
            steps {
                dir('terraform') {
                    sh '''
                        # Try to import SG if it exists in AWS
                        SG_ID=$(aws ec2 describe-security-groups \
                            --filters "Name=group-name,Values=flask-app-sg" \
                            --region ${TF_VAR_region} \
                            --query "SecurityGroups[0].GroupId" \
                            --output text 2>/dev/null || true)

                        if [ "$SG_ID" != "None" ] && [ -n "$SG_ID" ]; then
                            echo "Found existing SG: $SG_ID, importing into Terraform state..."
                            terraform import aws_security_group.flask_sg $SG_ID || true
                        else
                            echo "No existing SG found, skipping import."
                        fi
                    '''
                }
            }
        }

        stage('Provision Infrastructure') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir('terraform') {
                        sh '''
                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                            
                            terraform apply -auto-approve \
                                -var="aws_access_key=${AWS_ACCESS_KEY_ID}" \
                                -var="aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
                                -var="key_name=terraform-generated-key" \
                                -var="private_key_path=/path/to/terraform-generated-key.pem"
                        '''
                    }
                }
            }
        }

        stage('Configure & Deploy with Ansible') {
            steps {
                dir('ansible') {
                    sh 'ansible-playbook -i inventory.ini playbook.yml'
                }
            }
        }

        stage('Build App') {
            steps {
                sh 'chmod +x build.sh && ./build.sh'
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    def result = sh(script: 'docker compose build --no-cache', returnStatus: true)
                    if (result != 0) {
                        sh 'docker compose logs || true'
                        error 'Docker Compose build failed'
                    }
                }
            }
        }

        stage('Run Containers') {
            steps {
                script {
                    def result = sh(script: 'docker compose up -d', returnStatus: true)
                    if (result != 0) {
                        sh 'docker compose logs || true'
                        error 'Failed to start containers'
                    }
                }
            }
        }

        stage('Verify Containers & Flask Status') {
            steps {
                sh '''
                    echo "Running containers:"
                    docker ps

                    echo "Flask container logs:"
                    docker logs $(docker ps -q --filter "name=ecommerce-app") || true

                    echo "Installed Python packages in Flask container:"
                    docker exec $(docker ps -q --filter "name=ecommerce-app") pip list || true
                '''
            }
        }

        stage('Wait for App to be Ready') {
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
                    # Add your Selenium test commands here
                '''
            }
        }
    }

    post {
        always {
            echo "Ensuring containers are up"
            sh 'docker compose up -d || true'
        }
    }
}








