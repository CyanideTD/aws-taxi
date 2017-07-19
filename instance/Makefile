#Configure variables
TF := terraform
TF_FLAGS := -var-file=$(TF_CONFIG_VARS)
USER ?= `whoami`
AS  := ansible
ASP := ansible-playbook


read_input = $(shell read -p $(1) REPLY; \
        if [ -z "$${REPLY}" ]; then echo $(2); else echo $${REPLY}; fi)

all: help
help:
	@echo "  ami		build customized AMI"
	@echo "  plan		create infrastructure plan"
	@echo "  apply		apply infrastructure plan"
	@echo "  deploy         deploy ansible playbook"
.PHONY: ami
ami:
	./build_ami.sh

.PHONY: plan
plan:
	terraform plan -var-file=cluster.tfvars
	
.PHONY: apply
apply:
	terraform apply -var-file=cluster.tfvars
	terraform output -json | ./json2ini.py --keywords webservers,mappers,reducers,dockers -o hosts

.PHONY: deploy
deploy:
	@echo "Deploying Ansible playbook"
	ansible-playbook deploy.yaml
