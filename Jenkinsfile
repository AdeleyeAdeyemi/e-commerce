pipeline {
    agent any

    options {
        skipDefaultCheckout()
    }

    environment {
        TERRAFORM_DIR         = "Terraform_module/terraform_project"
        PEM_CREDENTIALS_ID    = "aws-pem-key"
        AWS_CREDENTIALS_ID    = "terraform_autho"
        GITHUB_CREDENTIALS_ID = "github-credentials"
        BRANCH_NAME           = "main"
        REGION                = "us-east-2"
        IMAGE_TAG             = "latest"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${BRANCH_NAME}"]],
                    userRemoteConfigs: [[
                        url: 'https://github.com/AdeleyeAdeyemi/e-commerce',
                        credentialsId: "${GITHUB_CREDENTIALS_ID}"
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
                    ),
                    file(
                        credentialsId: 'terraform-tfvars',
                        variable: 'TFVARS_FILE'
                    )
                ]) {
                    dir("${TERRAFORM_DIR}") {
                        sh '''
                            set -e

                            trap 'rm -f environments/dev/terraform.tfvars tfplan' EXIT

                            echo "========================================"
                            echo "Terraform directory:"
                            pwd
                            echo "========================================"

                            echo "Terraform files:"
                            ls -la

                            echo "Environment directory:"
                            ls -la environments/dev || true

                            echo "Copying Terraform variables..."
                            cp "$TFVARS_FILE" environments/dev/terraform.tfvars

                            echo "Initializing Terraform..."
                            terraform init -reconfigure

                            echo "Validating Terraform..."
                            terraform validate

                            echo "Planning Terraform..."
                            terraform plan \
                                -var-file=environments/dev/terraform.tfvars \
                                -out=tfplan

                            echo "Applying Terraform plan..."
                            terraform apply -auto-approve tfplan

                            echo "Terraform apply completed successfully."
                        '''
                    }
                }
            }

            post {
                failure {
                    withCredentials([
                        usernamePassword(
                            credentialsId: "${AWS_CREDENTIALS_ID}",
                            usernameVariable: 'AWS_ACCESS_KEY_ID',
                            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                        ),
                        file(
                            credentialsId: 'terraform-tfvars',
                            variable: 'TFVARS_FILE'
                        )
                    ]) {
                        dir("${TERRAFORM_DIR}") {
                            sh '''
                                set +e

                                echo "========================================"
                                echo "TERRAFORM DEPLOYMENT FAILED"
                                echo "Starting automatic Terraform cleanup..."
                                echo "========================================"

                                cp "$TFVARS_FILE" environments/dev/terraform.tfvars

                                echo "Re-initializing Terraform..."
                                terraform init -reconfigure

                                echo "Resources currently in Terraform state:"
                                terraform state list || true

                                echo "========================================"
                                echo "DESTROYING TERRAFORM RESOURCES"
                                echo "========================================"

                                terraform destroy \
                                    -auto-approve \
                                    -var-file=environments/dev/terraform.tfvars

                                DESTROY_STATUS=$?

                                if [ "$DESTROY_STATUS" -eq 0 ]; then
                                    echo "Terraform cleanup completed successfully."
                                else
                                    echo "WARNING: Terraform cleanup FAILED."
                                    echo "Resources may still exist in AWS."
                                fi

                                rm -f environments/dev/terraform.tfvars
                                rm -f tfplan
                            '''
                        }
                    }
                }
            }
        }

        stage('Prepare Ansible Inventory') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: "${AWS_CREDENTIALS_ID}",
                            usernameVariable: 'AWS_ACCESS_KEY_ID',
                            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                        ),
                        file(
                            credentialsId: "${PEM_CREDENTIALS_ID}",
                            variable: 'PEM_FILE'
                        )
                    ]) {
                        def publicIp = sh(
                            script: "terraform -chdir=${TERRAFORM_DIR} output -raw public_ip",
                            returnStdout: true
                        ).trim()

                        sh """
                            cp '${PEM_FILE}' '${WORKSPACE}/jenkins-key.pem'
                            chmod 600 '${WORKSPACE}/jenkins-key.pem'
                        """

                        def pemFile = "${WORKSPACE}/jenkins-key.pem"

                        def inventory = """
all:
  hosts:
    ${publicIp}:
      ansible_user: ec2-user
      ansible_ssh_private_key_file: ${pemFile}
      ansible_python_interpreter: /usr/bin/python3
      ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
"""

                        writeFile(
                            file: 'inventory_generated.yml',
                            text: inventory
                        )

                        echo "Ansible inventory created:\n${inventory}"
                    }
                }
            }
        }

        stage('Configure & Deploy with Ansible') {
            steps {
                sh 'ansible-playbook -i inventory_generated.yml ansible/playbook.yml'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def buildResult = sh(
                        script: 'docker build -t ecommerce-app:latest .',
                        returnStatus: true
                    )

                    if (buildResult != 0) {
                        sh '''
                            docker logs $(docker ps -q --filter "name=ecommerce-app") || true
                        '''

                        error "Docker build failed"
                    }
                }
            }
        }

        stage('Verify Image') {
            steps {
                sh '''
                    docker run --rm --entrypoint python3 ecommerce-app:latest --version
                    docker run --rm --entrypoint python3 ecommerce-app:latest -m pip list
                    
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login \
                            -u "$DOCKER_USER" \
                            --password-stdin

                        docker tag \
                            ecommerce-app:latest \
                            "$DOCKER_USER/ecommerce-app:${IMAGE_TAG}"

                        docker push \
                            "$DOCKER_USER/ecommerce-app:${IMAGE_TAG}"
                    '''
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts(
                    artifacts: '**/*.py',
                    fingerprint: true
                )
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

                    chmod +x venv/bin/python3

                    ./venv/bin/python3 -m pip install \
                        --upgrade "pip<24" setuptools wheel

                    ./venv/bin/python3 -m pip install \
                        -r requirements.txt pytest selenium

                    ./venv/bin/python3 -m pytest \
                        tests/selenium \
                        --maxfail=1 \
                        --disable-warnings \
                        -q
                '''
            }
        }
    }

    post {
        always {
            echo 'Ensuring all containers are running'

            sh '''
                rm -f "${WORKSPACE}/jenkins-key.pem" || true
                rm -f "${WORKSPACE}/inventory_generated.yml" || true
            '''
        }
    }
}
    

















