# E-Commerce App CI/CD Pipeline

This repository contains a **Flask-based e-commerce application** and a complete **CI/CD pipeline** using **Jenkins**, **Docker**, **Terraform**, **Ansible**, and optionally **Kubernetes (KIND)** for local testing. The pipeline automatically provisions infrastructure, deploys the app, builds Docker images, pushes to Docker Hub, and runs Selenium tests.

---

## Features

- Infrastructure provisioning with **Terraform** (AWS EC2)
- Application deployment with **Ansible**
- Containerization with **Docker**
- Automated CI/CD with **Jenkins**
- Local Kubernetes testing with **KIND** 
- Automated Selenium UI tests


---

## Prerequisites

- Jenkins with Docker access
- Docker & Docker Compose
- Terraform
- Ansible
- Python 3.10+ for Flask
- AWS credentials (Terraform)
- Selenium for UI tests

---

## Pipeline Overview

1. **Checkout Code**  
   Jenkins pulls the repository from GitHub.

2. **Terraform Init & Apply**  
   - Creates EC2 instance and SSH key.
   - Outputs EC2 public IP and private key path.

3. **Prepare Ansible Inventory**  
   - Generates an inventory file with EC2 IP and SSH key.

4. **Configure & Deploy with Ansible**  
   - Installs Docker, Docker Compose.
   - Clones repo and runs Docker Compose.

5. **Build & Verify Docker Image**  
   - Builds Docker image of the Flask app.
   - Runs container locally to verify Python version and dependencies.

6. **Push Docker Image to Docker Hub**  
   - Tags and pushes the image.

7. **Verify App & Containers**  
   - Ensures all containers are running:
     - Flask app (`ecommerce-app`)
     - ELK stack (Elasticsearch, Logstash, Kibana)

8. **Run Selenium Tests**  
   - Uses `pytest` and `selenium` to verify UI functionality.

---

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/AdeleyeAdeyemi/e-commerce.git
cd e-commerce
# e-commerce2
