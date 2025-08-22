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
                    sh 'ansi

                    







