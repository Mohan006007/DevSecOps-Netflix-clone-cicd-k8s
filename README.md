# DevSecOps Netflix Clone Deployment
A simple Netflix Clone made using [Next.js](https://nextjs.org/) ⚡

Currently, I have implemented the basic UI with media details fetch functionality.


Deployed it using vercel [here](https://nextflix-azure.vercel.app/).

Please leave a ⭐ as motivation if you liked the implementation 😄


## Demo
![Demo](/public/assets/demo.gif)

<img width="1919" height="1016" alt="Screenshot 2026-03-28 034622" src="https://github.com/user-attachments/assets/748efe8c-63fb-4f2d-863d-99da084a1c4d" />

<img width="1919" height="1013" alt="Screenshot 2026-03-28 035023" src="https://github.com/user-attachments/assets/26a32803-6667-420b-8dd7-32c5788c5a57" />

<img width="1919" height="1010" alt="Screenshot 2026-03-28 034825" src="https://github.com/user-attachments/assets/7a66555b-01e1-4099-bb7c-72890fc3ae99" />

<img width="1919" height="1019" alt="Screenshot 2026-03-28 035000" src="https://github.com/user-attachments/assets/a0481037-5006-438e-89af-7aeec4664405" />

<img width="1919" height="1019" alt="Screenshot 2026-03-28 035000" src="https://github.com/user-attachments/assets/87f9e57b-d6d8-432e-a428-ad46b4b43bba" />

<br />
<br />

## Built with
* [Next.js](https://nextjs.org/)
* [Typescript](https://www.typescriptlang.org/)
* [Sass](https://sass-lang.com/)
* [TMDB API](https://www.themoviedb.org/)


## Running the project
This is a [Next.js](https://nextjs.org/) project bootstrapped with [`create-next-app`](https://github.com/vercel/next.js/tree/canary/packages/create-next-app).

In the project directory, you can run:

#### `yarn start`

It runs the app in the development mode.<br />
Open [http://localhost:3000](http://localhost:3000) to view it in the browser. 


# Deploying a Netflix Clone on Kubernetes using DevSecOps methodology

In this project we would be deploying Netflix Clone application on an EKS cluster using DevSecOps methodology. We would be making use of security tools like SonarQube, OWASP Dependency Check and Trivy.
We would also be monitoring our EKS cluster using monitoring tools like Prometheus and Grafana. Most importantly we will be using ArgoCD for the Deployment.

## Step 1: Launch an EC2 Instance and install Jenkins, SonarQube, Docker and Trivy

We would be making use of Terraform to launch the EC2 instance. We would be adding a script as userdata for the installation of Jenkins, SonarQube, Trivy and Docker. 

## Step 2: Access Jenkins at port 8080 and install required plugins

Install the following plugins:

1. NodeJS 
2. Eclipse Temurin Installer
3. SonarQube Scanner
4. OWASP Dependency Check
5. Docker
6. Docker Commons
7. Docker Pipeline
8. Docker API
9. docker-build-step

## Step 3: Set up SonarQube

For the SonarQube Configuration, first access the Sonarqube Dashboard using the url http://elastic_ip:9000

1. Create the token 
Administration -> Security -> Users -> Create a token 

2. Add this token as a credential in Jenkins 

3. Go to Manage Jenkins -> System -> SonarQube installation 
Add URL of SonarQube and for the credential select the one added in step 2.

4. Go to Manage Jenkins -> Tools -> SonarQube Scanner Installations
-> Install automatically.

## Step 4: Set up OWASP Dependency Check 

1. Go to Manage Jenkins -> Tools -> Dependency-Check Installations
-> Install automatically

## Step 5: Set up Docker for Jenkins

1. Go to Manage Jenkins -> Tools -> Docker Installations -> Install automatically

2. And then go to Manage Jenkins -> Credentials -> System -> Global Credentials -> Add credentials. Add username and password for the docker registry (You need to create an account on Dockerhub). 

## Step 6: Create a pipeline in order to build and push the dockerized image securely using multiple security tools

Go to Dashboard -> New Item -> Pipeline 

Use the code below for the Jenkins pipeline. 

```bash
pipeline {
    agent any

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        DOCKER_IMAGE = "mohan006007/netflix:latest"
    }

    stages {

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Mohan006007/DevSecOps-Netflix-clone-cicd-k8s.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh """
                    $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectName=Netflix \
                    -Dsonar.projectKey=Netflix
                    """
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'OWASP DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Trivy File System Scan') {
            steps {
                sh "trivy fs . --exit-code 0 --severity HIGH,CRITICAL > trivyfs.txt"
            }
        }

        stage('Build Docker Image') {
            steps {
                withCredentials([string(credentialsId: 'api-key', variable: 'API_KEY')]) {
                    sh """
                    docker build \
                    --build-arg API_KEY=$API_KEY \
                    -t netflix .
                    """
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh "trivy image --exit-code 0 --severity HIGH,CRITICAL netflix > trivyimage.txt"
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                        sh "docker tag netflix ${DOCKER_IMAGE}"
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '*.txt', allowEmptyArchive: true
        }
        success {
            echo "Pipeline executed successfully 🚀"
        }
        failure {
            echo "Pipeline failed ❌"
        }
    }
}
```

## Step 7: Create an EKS Cluster using Terraform 

Prerequisite: Install kubectl and helm before executing the commands below 

## Step 8: Deploy Prometheus and Grafana on EKS 

In order to access the cluster use the command below:

```
aws eks update-kubeconfig --name "Cluster-Name" --region "Region-of-operation"
```

1. We need to add the Helm Stable Charts for your local.

```bash
helm repo add stable https://charts.helm.sh/stable
```

2. Add prometheus Helm repo

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

3. Create Prometheus namespace

```bash
kubectl create namespace prometheus
```

4. Install kube-prometheus stack

```bash
helm install stable prometheus-community/kube-prometheus-stack -n prometheus
```

5. Edit the service and make it LoadBalancer

```
kubectl edit svc stable-kube-prometheus-sta-prometheus -n prometheus
```

6. Edit the grafana service too to change it to LoadBalancer

```
kubectl edit svc stable-grafana -n prometheus
```

## Step 9: Deploy ArgoCD on EKS to fetch the manifest files to the cluster

1. Create a namespace argocd
```
kubectl create namespace argocd
```

2. Add argocd repo locally
```
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.7/manifests/install.yaml
```

3. By default, argocd-server is not publically exposed. In this scenario, we will use a Load Balancer to make it usable:
```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

4. We get the load balancer hostname using the command below:
```
kubectl get svc argocd-server -n argocd -o json
```

5. Once you get the load balancer hostname details, you can access the ArgoCD dashboard through it.

6. We need to enter the Username and Password for ArgoCD. The username will be admin by default. For the password, we need to run the command below:
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
