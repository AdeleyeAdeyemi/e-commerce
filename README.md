E-Commerce CI/CD Pipeline

Overview

This project implements an automated CI/CD pipeline for the My Shop
Flask e-commerce application using Jenkins, Terraform, Docker, Docker
Hub, Ansible, Minikube, Kubernetes, and Selenium.

The pipeline provisions AWS infrastructure, builds and publishes the
application container, configures an EC2 host, deploys the application
to Kubernetes, exposes it through NodePort 31804, and runs automated
Selenium tests.

Repository

GitHub repository:

https://github.com/AdeleyeAdeyemi/e-commerce

Technology Stack

Jenkins --- CI/CD orchestration

GitHub --- source-code repository

Terraform --- AWS infrastructure provisioning

AWS EC2 --- application/deployment host

AWS S3 --- Terraform remote state backend

Docker --- application containerization

Docker Hub --- container image registry

Ansible --- EC2 configuration and application deployment

Minikube --- local Kubernetes cluster running on EC2

Kubernetes --- application orchestration

socat --- forwards EC2 port 31804 to the Minikube NodePort

Selenium / Pytest --- application testing

Flask --- web application framework

Pipeline Flow

GitHub
   |
   v
Jenkins Checkout
   |
   v
Terraform Init / Validate / Plan / Apply
   |
   v
AWS Infrastructure
   |
   v
Docker Build
   |
   v
Docker Image Verification
   |
   v
Push Image to Docker Hub
   |
   v
Generate Ansible Inventory
   |
   v
Ansible Configuration
   |
   +--> Install Docker
   +--> Install kubectl
   +--> Install Minikube
   +--> Start Minikube
   +--> Copy Kubernetes manifests
   +--> Apply Kubernetes manifests
   +--> Install/configure socat
   |
   v
Application Verification
   |
   v
Selenium Tests
   |
   v
Jenkins SUCCESS

Jenkins Pipeline Stages

1. Checkout SCM

Jenkins retrieves the main branch from GitHub.

The recorded successful build checked out:

Commit: a582273ae831b2ae0fa912bcef0858e714bb1983
Message: Update main.tf

2. Terraform Init & Apply

Terraform runs from:

Terraform_module/terraform_project

The pipeline:

Copies the protected terraform.tfvars Jenkins credential into
environments/dev/.

Initializes the Terraform S3 backend.

Validates the configuration.

Creates a Terraform plan.

Applies the plan.

Removes the temporary terraform.tfvars and plan file.

The deployment uses an S3 backend so Terraform state is retained
remotely.

Example successful result:

Terraform has been successfully initialized!
Success! The configuration is valid.
No changes. Your infrastructure matches the configuration.
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

The Terraform output provides the current EC2 public IP:

public_ip = "3.145.2.209"

The EC2 public IP is dynamic and should not be hard-coded. Jenkins
should obtain it from Terraform output.

3. Build Docker Image

Jenkins builds:

ecommerce-app:latest

The application uses a multi-stage Docker build with a Python builder
image and a Distroless Python runtime.

4. Verify Docker Image

The image is verified using Python:

docker run --rm --entrypoint python3 ecommerce-app:latest --version

and Flask import validation:

docker run --rm --entrypoint python3 ecommerce-app:latest \
  -c "import flask; print('Flask installed successfully')"

Successful output confirms that Python and Flask are available in the
final image.

5. Push to Docker Hub

Jenkins authenticates to Docker Hub using Jenkins credentials and
pushes:

<DOCKER_USER>/ecommerce-app:latest

The Docker Hub credentials are stored in Jenkins and are not hard-coded
in the Jenkinsfile.

6. Prepare Ansible Inventory

Jenkins obtains the EC2 public IP directly from Terraform:

terraform -chdir=Terraform_module/terraform_project output -raw public_ip

It then generates an Ansible inventory containing:

EC2 public IP

ec2-user

Jenkins-managed SSH private key

Python 3 interpreter

SSH options for non-interactive deployment

7. Configure & Deploy with Ansible

Ansible configures the EC2 instance automatically.

The deployment performs tasks including:

Install required system packages

Start Docker

Add ec2-user to the Docker group

Clone the GitHub repository

Install kubectl

Install Minikube

Start Minikube with the Docker driver

Copy Kubernetes manifests

Create the Kubernetes namespace

Apply Kubernetes manifests

Verify Minikube nodes

Install socat

Create the systemd forwarding service

Enable the forwarding service

Verify the application endpoint

8. Kubernetes Deployment

The application runs in Minikube.

The Kubernetes service is configured as:

apiVersion: v1
kind: Service
metadata:
  name: ecommerce-service
spec:
  type: NodePort
  selector:
    app: ecommerce
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8777
      nodePort: 31804

Important port mapping:

Kubernetes Service :80
        |
        v
NodePort :31804
        |
        v
Flask Container :8777

The Flask application must listen on:

0.0.0.0:8777

9. EC2 Port Forwarding

Because Minikube uses the Docker driver, its NodePort is inside the
Minikube network.

socat forwards the EC2 public-facing port to the Minikube NodePort:

EC2 :31804
    |
    v
socat
    |
    v
Minikube :31804
    |
    v
Kubernetes Service
    |
    v
Flask Pod :8777

The systemd service is:

/etc/systemd/system/ecommerce-nodeport.service

It is enabled so that the forwarding service starts automatically.

10. Application Verification

The deployment should verify the application locally on EC2:

curl http://127.0.0.1:31804

A successful response should contain:

HTTP/1.1 200 OK

and the My Shop application HTML.

Do not use the EC2 public IP for the local Ansible health check.
Testing:

http://127.0.0.1:31804

avoids EC2 public-IP hairpinning issues.

11. Selenium Tests

Jenkins creates/uses the Python virtual environment and installs:

pytest
selenium

Then it runs:

./venv/bin/python3 -m pytest tests/selenium \
  --maxfail=1 \
  --disable-warnings \
  -q

The Selenium tests provide application-level validation after
deployment.

Application

The deployed application is a Flask e-commerce site called My Shop.

The homepage provides:

Red T-Shirt --- $19.99

Blue Jeans --- $49.99

Sneakers --- $89.99

Cart functionality

Product pages

The application is exposed externally through:

http://<EC2_PUBLIC_IP>:31804

Example:

http://3.145.2.209:31804

The public IP changes when Terraform creates a new EC2 instance, so
always obtain the current IP from Terraform.

AWS Security Group

TCP port 31804 must be allowed in the security group attached to the
EC2 instance.

Recommended Terraform rule:

ingress {
  description = "E-commerce Kubernetes NodePort"
  from_port   = 31804
  to_port     = 31804
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

This rule should be managed by Terraform rather than added manually in
the AWS console.

Jenkins Credentials

The pipeline expects Jenkins-managed credentials for:

GitHub access

AWS authentication

Terraform variables

EC2 SSH private key

Docker Hub authentication

Secrets should never be committed to GitHub or hard-coded in the
Jenkinsfile.

Temporary files such as the SSH key and generated Ansible inventory
should be removed during post-build cleanup.

Important Pipeline Improvement

The recorded pipeline contains:

Warning: CredentialId "github-credentials" could not be found.

Even though checkout succeeded, the missing credential should be fixed
in Jenkins if the repository is intended to use authenticated GitHub
access.

The pipeline also currently contains:

Verify App & Containers
    docker ps

Wait for App Ready
    sleep 30

docker ps on the Jenkins machine does not verify the Kubernetes
application because the application runs inside Minikube on the EC2
host.

A stronger verification is:

ssh ec2-user@<EC2_PUBLIC_IP> \
  'curl --fail --silent http://127.0.0.1:31804'

This makes Jenkins fail when the deployed application is not actually
reachable.

Terraform Cleanup

To destroy infrastructure provisioned by this Terraform project:

cd ~/e-commerce/Terraform_module/terraform_project

terraform init -reconfigure

terraform plan -destroy \
  -var-file=environments/dev/terraform.tfvars

terraform destroy -auto-approve \
  -var-file=environments/dev/terraform.tfvars

After destruction:

terraform state list

should return no managed resources.

Do not manually delete the S3 backend bucket used to store Terraform
state unless you intentionally want to remove the Terraform backend
itself.

Troubleshooting

Kubernetes pods are not running

Check:

/home/ec2-user/bin/kubectl get pods

Then inspect logs:

/home/ec2-user/bin/kubectl logs <pod-name>

Service is using the wrong NodePort

Check:

/home/ec2-user/bin/kubectl get svc ecommerce-service

Expected:

80:31804/TCP

If another NodePort is shown, check the Kubernetes service manifest.

Flask connection refused

Check the endpoints:

/home/ec2-user/bin/kubectl get endpoints ecommerce-service

The endpoints should use port 8777.

socat is failing

Check:

sudo systemctl status ecommerce-nodeport.service --no-pager

and:

sudo journalctl -u ecommerce-nodeport.service -n 50 --no-pager

Application works on localhost but not from the Internet

Verify:

Current EC2 public IP.

AWS Security Group allows TCP 31804.

socat is listening on 0.0.0.0:31804.

Check:

sudo ss -lntp | grep 31804

Minikube NodePort does not work

Check:

/home/ec2-user/bin/minikube ip

Then:

curl -v http://$(/home/ec2-user/bin/minikube ip):31804

If this fails, troubleshoot Kubernetes/Minikube before troubleshooting
socat.

Successful Deployment Evidence

The recorded Jenkins deployment completed with:

PLAY RECAP
ok=23
changed=18
unreachable=0
failed=0
skipped=0
rescued=0
ignored=0

The Ansible application verification completed successfully:

TASK [Verify ecommerce NodePort forwarding]
ok

The Jenkins pipeline finished:

Finished: SUCCESS

The deployed application returned:

HTTP/1.1 200 OK

with the expected My Shop product page.

Security Notes

Never commit AWS credentials.

Never commit Docker Hub passwords or access tokens.

Never commit private SSH keys.

Keep terraform.tfvars out of source control when it contains
secrets.

Use Jenkins Credentials for sensitive values.

Use Terraform as the source of truth for AWS infrastructure.

Avoid hard-coding dynamic EC2 public IP addresses.

Prefer a stable Elastic IP or DNS name if a permanent application
URL is required.

Conclusion

This project provides an automated deployment path from source control
to a publicly accessible Flask application:

GitHub
  -> Jenkins
  -> Terraform
  -> AWS
  -> Docker
  -> Docker Hub
  -> Ansible
  -> Minikube
  -> Kubernetes
  -> NodePort 31804
  -> socat
  -> Flask
  -> Selenium

The recorded deployment successfully provisioned/configured the
environment, deployed the application, verified the Kubernetes
forwarding endpoint, and completed the Jenkins pipeline with SUCCESS
git clone https://github.com/AdeleyeAdeyemi/e-commerce.git
cd e-commerce
# e-commerce2
