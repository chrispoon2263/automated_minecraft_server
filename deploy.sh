#!/bin/bash

# Provision AWS EC2
cd terraform
terraform apply -auto-approve

IP=$(terraform output -raw instance_public_ip)

cd ..
cd ansible
echo $PWD
echo "[servers]" > ./inventory/hosts.ini
echo "$IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/minecraft_key.pem" >> ./inventory/hosts.ini
cat ./inventory/hosts.ini
ansible-playbook -i ./inventory/hosts.ini ./playbooks/minecraft.yaml