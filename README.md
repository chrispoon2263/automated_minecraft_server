
# CI/CD Auto Deployment Minecraft Server
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)![Ansible](https://img.shields.io/badge/ansible-%231A1918.svg?style=for-the-badge&logo=ansible&logoColor=white)![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)

## Table of Contents
1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Cloud Architecture](#cloud-architecture)
4. [Setup and Execution](#setup-and-execution)
5. [Resources](#resources)
## Overview 
 - CI/CD pipeline that deploys a Minecraft server onto AWS via docker container.
 - Terraform will create the EC2 instance on AWS.
 - Ansible will configure the EC2 instance to pull the custom Minecraft [Docker container](https://hub.docker.com/r/chrispoon2263/minecraft-server)   
 - Deployment can be either locally or via GitHub Actions push.
 - Take a look at the  [Cloud Architecture](#architecture) for a broad overview

---
## Requirements
1. Make sure to install [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli),  [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html), [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), and [nmap](https://nmap.org/download.html)
2. Grab the initial files and cd into the directory
```bash
$ git clone https://github.com/chrispoon2263/automated_minecraft_server.git

$ cd automated_minecraft_server
```

3. Create SSH key on AWS
	- EC2 Dashboard -> Key Pairs on left menu -> Create Key Pair-> Pick RSA or ED25519 ->name the key minecraft_key -> pick .pem -> hit create and will download to your machine
	- Place the newly generated key  minecraft_key.pem in ~/.ssh/ folder

4. Grab AWS credentials from your AWS account
```bash
$ aws configure
```
> [!TIP]
>  - AWS will place the credentials in ~/.aws/credentials
>  - If you have a student learner account make sure to also add your aws_session_token at the end of the file


> [!IMPORTANT]
> - Only have to run this one time to provision an S3 bucket and place first Minecraft Server settings and Terraform state into S3 whether doing local or push deployment

5. Run the initial setup to create S3 bucket on AWS if not already provisioned
```bash
$ source initial_setup.sh
```

6. To allow E2E deployment via GitHub Actions go to Github Settings -> Secrete and Variables -> Actions -> new repository secret and add the following variables:
	- AWS_ACCESS_KEY_ID
	- AWS_SECRET_ACCESS_KEY
	- AWS_SESSION_TOKEN       (only for student learner accounts)
	- DOCKERHUB_TOKEN          (Will push to your Dockerhub)
	- DOCKERHUB_USERNAME  (Will push to your Dockerhub)
	- SSH_MINECRAFT_KEY        (The newly generated key from above)


---

## Cloud Architecture
 ![alt text](images/CloudArchitecture.png)
> [!Note]
> - Can be done locally or via github push. 
> - Data storage will be handled using S3 bucket so even if the EC2 instance is destroyed the terraform state and Minecraft server settings will persist.

### Step 1
- Upon a Git push, the custom Dockerfile with a Minecraft server will be tested using GitHub Actions. 
- The Git runner will build the container and check if the docker container's minecraft server is able to turn on. If the test passes, the Docker image will be pushed to DockerHub.
### Step 2 
- The Git runner will then provision an AWS EC2 instance using Terraform
	- It will first sync to the S3 AWS bucket to grab the latest terraform state
	- The VPN will expose port 25565 for Minecraft Server
### Step 3
- The Git runner will then run an Ansible Playbook that installs Docker and pulls the custom Docker image from earlier and runs the Docker container inside the EC2 instance.
- The custom container will immediately start up the Minecraft Server using the latest S3 storage Minecraft settings
- The container is instructed to restart if the docker containers fails or EC2 instance is rebooted. 
### Step 4
- The Docker container will expose port 25565 as well for the Minecraft Server
- Any players or clients can now reach the Minecraft Server with the given IPv4 address and port 25565



---
## Setup and Execution

> [!TIP]
>  - You can deploy either locally or from push


#### Deploy from local machine CI/CD
1. This will call Terraform apply to create the EC2 instance, Run the Ansible Playbook to start the Docker Container, and Test if the Minecraft server is running.
	- You can call this command if make any changes to the Terraform files or Ansible playbook
```bash
# Create the needed environment variables
$ source initial_setup.sh

# Runs the entire pipeline locally
$ make all
```

2. This will destroy the EC2 instance but will first sync the Minecraft Server settings & Terraform state to S3 before destroying the EC2 instance
```bash
$ make destroy
```


#### Deploy on push using GitHub Actions CI/CD
1. Make a change to the docker, terraform files, or ansible playbook and push to GitHub to start the CI/CD Deployment 
2. Upon push it will follow the architecture diagram above: [Architecture](#architecture)
```bash
$ git push
```

#### Connect to Minecraft Server
- On Minecraft -> Multiplayer -> Add Server -> <public IPv4 of AWS EC2 instance>:25565
- The public IP address will be printed out from the terminal after running "make all" or push deployment
- If no Minecraft then use this to test if the Minecraft server is open:
```bash
$ nmap -Pn -p 25565 <public IPv4 of AWS EC2 instance>
```
---

## Resources
- https://www.minecraft.net/en-us/download/server
- https://minecraft.wiki/w/Tutorial:Setting_up_a_Java_Edition_server
- https://minecraft.wiki/w/Server.properties#Java_Edition
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
- https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html
- https://docs.docker.com/