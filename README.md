# Flask Application Deployment on Amazon EKS

This document outlines the steps taken to deploy a **Python Flask application** as a microservice on an Amazon EKS (Elastic Kubernetes Service) cluster using **Docker** and **Terraform**.

---

##  Step 1: Clone the Repository & Initial Setup

This step involves setting up the local development environment and verifying the application runs locally.

| Commands / Actions | Files Modified | Result | Notes |
|:---|:---|:---|:---|
| Creating a clean Conda environment: `conda create --name flask_project python=3.9` | |  |  |
| Activating the environment: `conda activate flask_project` |  ||  |
| Installing Dependencies: `pip install -r requirements.txt` | `requirements.txt` | |  |
| Running the Flask app: `flask run` | | Application accessible on `localhost`. | There was a dependency conflict thus i edited the requirements file|

---
![](/screenshots/dependency_conflict.png)
![](/screenshots/locally_working.png)

##  Step 2: Dockerize the Application

The application is containerized, and the image is pushed to **Dockerhub Registery**
| Commands / Actions | Files Modified | Result | Notes |
|:---|:---|:---|:---|
| Create the Dockerfile for the application. | `Dockerfile` | | Choosing a minimal Debian image and installing the python 3.11 version on top of that os <br> Exposing the port the application will run on which is “5000” as a default for flask applications<br>Using a guincorn as WSGI for production deployment with 4 workers for better concurrency|
| Build the Docker image: `docker build -t flask-app-image .` ||  |I used "play with docker" virtual sessions |
| Containerizing the application| `docker run -d -p 5000:5000 flask-app-image` |  |  |
| Pushing the image to public dockerhub registery |`docker push rawdarumaieh/flask-app-demo:latest`|  |this is not the best practice as in realife the image should not be a public one<br>if it was a private repo I had to create a Kubernetes imagePullSecret in the EKS cluster that holds your Docker Hub credentials and reference it in your deployment's imagePullSecrets field|

---
![](/screenshots/application_dockerized.png)




##  Step 3: Provision a Kubernetes Cluster

I used **Terraform**I to provision the necessary AWS networking and the EKS cluster itself.

| Commands / Actions | Files Modified | Result | Notes |
|:---|:---|:---|:---|
| 	Creating AWS free tier account, IAM policy , access keys  |  | |  |
| 	Creating the terraform files  | `main.tf`; `output.tf`; `variables.tf`; `versions.tf` | |VPC and Kubernetes are configured inside `main.tf`<br> RBAC for admin access is also configured inside the `main.tf`|
| `terraform init`; `terraform plan`; `terraform apply`| || || ||
---
![](/screenshots/cluster_created_in_aws.png)
##  Step 4&5: Deploy the Microservice and Expose the Service to the Internet
I used **LoadBalancer**


| Commands / Actions | Files Modified | Result | Notes |
|:---|:---|:---|:---|
| Configure `kubeconfig` so `kubectl` can connect to the EKS cluster using `aws eks update-kubeconfig --name <cluster_name>` 
| Flask application Pods are created and can be accessed externally|`service.yaml`</br>`deployment.yaml` |  |  |
---
![](/screenshots/service_accessed.png)

##  Step 6: Deployment

Implementing a CI/CD pipeline to automate the build and deployment process using **GitHub Actions**

| Commands / Actions | Files Modified | Result | Notes |
|:---|:---|:---|:---|
| 	Configuring GitHub Secrets for `AWS` and `DockerHub`   || |  |
| 	Configuring IAM policy on aws and attaching it to the user |  | ||
|Pipeline runs when a push event happens</br> it contains `build`and `deploy` sections|`deployment.yaml`||in this stage `Update Kubeconfig` i tried to run the command `aws eks update-kubeconfig --name ${{ secrets.EKS_CLUSTER_NAME }} --region ${{ secrets.AWS_REGION }}` in different ways yet the part `--region`was seen as a new line so I had to write the command without the secrets AKA *displaying the cluster name and region* I know this is not the best practice but I will be happy to discuss it.

![](/screenshots/CICD_success.png)
---


##  Step 7: Monitoring
I used Prometheus and Kubernetes Metrics Server
</br>
I ran into some challenges when using Prometheus due to the limited `Free Tier `Account resources


| Commands / Actions | Files Modified | Result | Notes |
|:---|:---|:---|:---|
| `helm install prometheus-metrics prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace --set alertmanager.enabled=false --set grafana.enabled=false --set prometheusOperator.admissionWebhooks.enabled=false --version 78.5.0 --set server.persistentVolume.enabled=false –set alertmanager.persistentVolume.enabled=false`||prometheus nodes were created but in a pending state |what I understood from the error that more pods needed to be created inside the node yet since I was using `T3.micro` instance this wasn't possible|
|I then found a pre-defined yaml that deploy a customized subset of prometheus removing some main modules to match my instance type</br>`prometheus-all.yaml`</br> it doesn't contain `Grafana` or `Alert Manager` it also disables `Persistent Volume` thus Prometheus can't retains past data even if the pod restarts| `prometheus-all.yaml` |I can monitor logs `locally`|in real life situation a `LoadBalancer` should be configured over `IP range` so it can be accessed by relevant parties</b> prometheus could return results from the *externally accessed resources* thus I believe I still need to debug the problem|
![](/screenshots/prometheus_installed.png)
![](/screenshots/pending_pods.png)
![](/screenshots/runs_locally.png)