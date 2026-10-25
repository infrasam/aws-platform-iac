# Usage: make <command> STACK=<bootstrap|cluster> [ENV=dev]
STACK ?= cluster
ENV   ?= dev
DIR   := infrastructure/$(STACK)

# Allow only your current public IP to reach the cluster APIs
export TF_VAR_admin_cidrs ?= ["$(shell curl -s https://checkip.amazonaws.com)/32"]

.DEFAULT_GOAL := help
.PHONY: help login init plan apply credentials fmt

# Where cluster credentials are saved, outside the repo
KUBECONFIG_FILE  := $(HOME)/.kube/aws-platform-iac-$(ENV).yaml
TALOSCONFIG_FILE := $(HOME)/.talos/aws-platform-iac-$(ENV).yaml

help: ## Show available commands
	@grep -E '^[a-z]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-12s %s\n", $$1, $$2}'

login: ## Sign in to AWS (once a day)
	aws login --profile lab

init: ## Download providers and connect to the S3 state
	terraform -chdir=$(DIR) init -backend-config=environments/$(ENV).backend.hcl

plan: ## Show what would change in AWS
	terraform -chdir=$(DIR) plan -var-file=environments/$(ENV).tfvars

apply: ## Apply the changes (asks for yes first)
	terraform -chdir=$(DIR) apply -var-file=environments/$(ENV).tfvars

credentials: ## Save kubeconfig and talosconfig for the cluster (private files)
	@mkdir -p $(dir $(KUBECONFIG_FILE)) $(dir $(TALOSCONFIG_FILE))
	@umask 077 && terraform -chdir=infrastructure/cluster output -raw kubeconfig > $(KUBECONFIG_FILE)
	@umask 077 && terraform -chdir=infrastructure/cluster output -raw talosconfig > $(TALOSCONFIG_FILE)
	@echo "Saved. Use them with:"
	@echo "  export KUBECONFIG=$(KUBECONFIG_FILE)"
	@echo "  export TALOSCONFIG=$(TALOSCONFIG_FILE)"

fmt: ## Format all Terraform files
	terraform fmt -recursive infrastructure
