pipeline {
    agent any

    environment {
        TF_WORKING_DIR = 'terraform'
        ANSIBLE_INVENTORY = 'ansible/inventory.ini'
        APP_DIR = 'ecommerce-app'
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
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    dir("${TF_WORKING_DIR}") {
                        sh """
                            terraform init
                            terraform plan -out=tfplan \\
                                -var="aws_access_key=${AWS_ACCESS_KEY_ID}" \\
                                -var="aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \\
                                -var="key_name=terraform-generated-key" \\
                                -var="region=eu-west-2"
                            terraform apply -auto-approve tfplan
                        """
                    }
                }
            }
        }

        stage('Prepare Ansible Inventory') {
            steps {
                dir("${TF_WORKING_DIR}") {
                    script {
                        def instance_ip = sh(
                            script: "terraform output -raw flask_app_public_ip",
                            returnStdout: true
                        ).trim()
                        writeFile file: "${ANSIBLE_INVENTORY}", text: """
                        [flask_app]
                        ${instance_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${WORKSPACE}/terraform/terraform-generated-key.pem
                        """
                    }
                }
            }
        }

        stage('Configure & Deploy with Ansible') {
            steps {
                sh """
                    ansible-playbook -i ${ANSIBLE_INVENTORY} ansible/deploy.yml
                """
            }
        }

        stage('Build & Run Docker') {
            steps {
                sh """
                    ssh -o StrictHostKeyChecking=no -i terraform/terraform-generated-key.pem ec2-user@$(terraform output -raw flask_app_public_ip) \\
                    'cd ${APP_DIR} && docker compose up -d --build'
                """
            }
        }

        stage('Verify App & Containers') {
            steps {
                sh """
                    ssh -o StrictHostKeyChecking=no -i terraform/terraform-generated-key.pem ec2-user@$(terraform output -raw flask_app_public_ip) \\
                    'docker ps'
                """
            }
        }

        stage('Run Selenium Tests') {
            steps {
                sh """
                    pytest tests/selenium --headless
                """
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
    }
}

