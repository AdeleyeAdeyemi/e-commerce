pipeline {
    agent any

    environment {
        TF_WORKING_DIR = 'terraform'
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
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
    }
}


