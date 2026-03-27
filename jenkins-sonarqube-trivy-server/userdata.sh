#!/bin/bash

# Update system
sudo yum update -y

# Install Git
sudo yum install git -y

# ---------------------------
# Install Jenkins (Latest LTS)
# ---------------------------
sudo wget -O /etc/yum.repos.d/jenkins.repo \
  https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Java 17 (still required)
sudo dnf install java-17-amazon-corretto -y

# Install Jenkins
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

# ---------------------------
# Install Docker (Updated way)
# ---------------------------
sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker

# Add users to Docker group
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins

# Fix Docker socket permission (optional but common)
sudo chmod 666 /var/run/docker.sock

# ---------------------------
# Install Trivy (Latest method)
# ---------------------------
sudo rpm -ivh https://github.com/aquasecurity/trivy/releases/latest/download/trivy-0.50.0-1.x86_64.rpm

# Verify Trivy
trivy --version

# ---------------------------
# Run SonarQube (Latest LTS)
# ---------------------------
docker run -d \
  --name sonar \
  -p 9000:9000 \
  sonarqube:lts