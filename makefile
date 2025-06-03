TERRAFORM_DIR=terraform
ANSIBLE_DIR=ansible
INVENTORY_FILE=$(ANSIBLE_DIR)/inventory/hosts.ini
PRIVATE_KEY=~/.ssh/minecraft_key
ANSIBLE_USER=ec2-user

.PHONY: all apply terraform ansible inventory destroy test

all: apply ansible test

apply:
	cd $(TERRAFORM_DIR) && terraform init -reconfigure
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve

inventory:
	@echo "Generating Ansible hosts.ini ..."
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip); \
	echo "[servers]" > $(INVENTORY_FILE); \
	echo "$$IP ansible_user=$(ANSIBLE_USER) ansible_ssh_private_key_file=$(PRIVATE_KEY)" >> $(INVENTORY_FILE); \
	for i in {1..10}; do \
		ssh-keyscan -H $$IP >> $(HOME)/.ssh/known_hosts && break; \
		echo "Retrying ssh scan, EC2 instance still provisioning..."; \
		sleep 7; \
	done

ansible: inventory
	ansible-playbook -i $(INVENTORY_FILE) $(ANSIBLE_DIR)/playbooks/minecraft.yaml

destroy:
	@echo "Syncing Minecraft data to S3 before destroying..."
	ansible-playbook -i $(INVENTORY_FILE) $(ANSIBLE_DIR)/playbooks/sync_to_s3.yaml && \
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve

test:
	@IP=$$(cd $(TERRAFORM_DIR) && terraform output -raw instance_public_ip); \
	for i in {1..10}; do \
		nmap -Pn -p 25565 $$IP | grep "open" && break;\
		echo "Retrying, Minecraft world still loading ..."; \
		sleep 10; \
	done; \
	echo "Minecraft Server public IP address at $$IP:25565" 
