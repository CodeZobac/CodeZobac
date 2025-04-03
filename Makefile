LOCK_ID ?= $(error Undefined LOCK_ID)

help:  ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Terraform variables and backend configuration
TERRAFORM_FOLDER=.
TERRAFORM_TFBACKEND=terraform.tfbackend
TERRAFORM_TFVARS=terraform.tfvars

# Docker related variables
DOCKER_IMAGE=hashicorp/terraform:1.9.5
DOCKER_WORKDIR=/terraform

# AWS related variables
SECRETS_ENV=$(shell pwd)/deploy/secrets.env

# Project related variables
DOMAIN ?= afonsocaboz.com
BUILD_DIR=deploy/clients/$(DOMAIN)

shell:  ## Open an interactive shell to use terraform cli with docker locally
	docker run \
		--env-file=$(SECRETS_ENV) \
		-it --rm  \
		--workdir $(DOCKER_WORKDIR) \
		--entrypoint /bin/sh \
		-v $(shell pwd):$(DOCKER_WORKDIR) \
		$(DOCKER_IMAGE)

format:  ## Format terraform files with terraform docker locally
	docker run \
		-it --rm \
		--workdir $(DOCKER_WORKDIR) \
		-v $(shell pwd):$(DOCKER_WORKDIR) \
		$(DOCKER_IMAGE) \
		fmt -recursive

init:  ## Init Terraform for an environment with terraform docker locally
	docker run \
		--env-file=$(SECRETS_ENV) \
		-it --rm \
		--workdir $(DOCKER_WORKDIR) \
		-v $(shell pwd):$(DOCKER_WORKDIR) \
		$(DOCKER_IMAGE) \
		-chdir=$(TERRAFORM_FOLDER) \
		init \
		-upgrade \
		-reconfigure \
		-var-file=$(TERRAFORM_TFVARS) \
		-backend-config=$(TERRAFORM_TFBACKEND)

validate: init  ## Validate terraform files with terraform docker locally
	docker run \
		-it --rm \
		--workdir $(DOCKER_WORKDIR) \
		-v $(shell pwd):$(DOCKER_WORKDIR) \
		$(DOCKER_IMAGE) \
		validate

plan: format validate ## Plan Terraform with terraform docker image
	docker run \
		--env-file=$(SECRETS_ENV) \
		-it --rm \
		--workdir $(DOCKER_WORKDIR) \
		-v $(shell pwd):$(DOCKER_WORKDIR) \
		$(DOCKER_IMAGE) \
		-chdir=$(TERRAFORM_FOLDER) \
		plan -out=plan.out \
		-var-file=$(TERRAFORM_TFVARS)

output:  ## Outputs Terraform with terraform docker image
	docker run \
		--env-file=$(SECRETS_ENV) \
		-it --rm \
		--workdir $(DOCKER_WORKDIR) \
		-v $(shell pwd):$(DOCKER_WORKDIR) \
		$(DOCKER_IMAGE) \
		-chdir=$(TERRAFORM_FOLDER) \
		output -json

apply: format validate ## Apply Terraform with terraform docker image
	docker run \
		-it --rm \
		--env-file=$(SECRETS_ENV) \
		--workdir $(DOCKER_WORKDIR) \
		-v $(shell pwd):$(DOCKER_WORKDIR) \
		$(DOCKER_IMAGE) \
		-chdir=$(TERRAFORM_FOLDER) \
		apply \
		-var-file=$(TERRAFORM_TFVARS)
		-lock=false

destroy: format validate ## Destroy Terraform with terraform docker image
	docker run \
		-it --rm \
		--env-file=$(SECRETS_ENV) \
		--workdir $(DOCKER_WORKDIR) \
		-v $(shell pwd):$(DOCKER_WORKDIR) \
		$(DOCKER_IMAGE) \
		-chdir=$(TERRAFORM_FOLDER) \
		destroy \
		-var-file=$(TERRAFORM_TFVARS)

unlock: ## Unlock Terraform with terraform docker image
	docker run \
		--env-file=$(SECRETS_ENV) \
		-it --rm \
		--workdir $(DOCKER_WORKDIR) \
		-v $(shell pwd):$(DOCKER_WORKDIR) \
		$(DOCKER_IMAGE) \
		-chdir=$(TERRAFORM_FOLDER) \
		force-unlock \
		$(LOCK_ID)

build: ## Build the static website for deployment
	@echo "Creating build directory..."
	mkdir -p $(BUILD_DIR)
	@echo "Copying source files..."
	cp -r src/* $(BUILD_DIR)/
	@echo "Copying public assets..."
	mkdir -p $(BUILD_DIR)/assets
	cp -r public/* $(BUILD_DIR)/assets/
	@echo "Updating asset references in HTML and CSS..."
	sed -i 's/\.\.\/public\//assets\//g' $(BUILD_DIR)/index.html
	sed -i 's/\.\.\/public\//assets\//g' $(BUILD_DIR)/style.css
	@echo "Creating error page..."
	cp $(BUILD_DIR)/index.html $(BUILD_DIR)/error.html
	@echo "Build completed!"

deploy: build ## Build and deploy the website to AWS
	cd deploy && $(MAKE) apply TERRAFORM_FOLDER=. TERRAFORM_TFVARS=variables.tf