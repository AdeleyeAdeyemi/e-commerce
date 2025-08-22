pipeline {
    agent any

    environment {
        TF_WORKING_DIR = 'terraform'
        APP_DIR        = 'app' // adjust to your Flask app directory
        INVENTORY_DIR  = 'ansible/inventory' // adjust if needed
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
                dir("${INVENTORY_DIR}") {
                    sh """
                        # Example: generate inventory from Terraform output
                        terraform -chdir=../${TF_WORKING_DIR} output -json > inventory.json
                        python generate_inventory.py inventory.json hosts.ini
                    """
                }
            }
        }

        stage('Configure & Deploy with Ansible') {
            steps {
                dir('ansible') {
                    sh """
                        ansible-playbook -i ${INVENTORY_DIR}/hosts.ini site.yml
                    """
                }
            }
        }

        stage('Build & Run Docker') {
            steps {
                dir("${APP_DIR}") {
                    sh """
                        docker compose build
                        docker compose up -d
                    """
                }
            }
        }

        stage('Verify App & Containers') {
            steps {
                sh """
                    docker ps
                    curl -f http://localhost:8777/ || echo "App not ready yet"
                """
            }
        }

        stage('Run Selenium Tests') {
            steps {
                sh """
                    # Assuming Selenium tests are in tests/selenium
                    pytest tests/selenium
                """
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
            dir("${APP_DIR}") {
                sh 'docker compose up -d'
            }
        }
    }
}
