# Makefile for Ansible Role Bootstrap Testing with molecule-qemu

# Default values
MOLECULE_MEMORY ?= 2048
MOLECULE_CPUS ?= 2
MOLECULE_DISK ?= 10G
MOLECULE_VERBOSE ?= false
MOLECULE_SSH_PORT ?= 2222

# Distribution configurations with cloud images
DEBIAN_DISTROS = ubuntu2204 ubuntu2004 debian12 debian11
RHEL_DISTROS = rocky9 rocky8 almalinux9 almalinux8
ALL_DISTROS = $(DEBIAN_DISTROS) $(RHEL_DISTROS)

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
NC = \033[0m # No Color

.PHONY: help test test-all test-debian test-rhel clean lint syntax check install-deps-qemu

# Default target
help:
	@echo "$(YELLOW)Ansible Role Bootstrap Testing with molecule-qemu$(NC)"
	@echo ""
	@echo "Available targets:"
	@echo "  $(GREEN)test$(NC)                 - Test default distribution (ubuntu2204)"
	@echo "  $(GREEN)test-all$(NC)             - Test all supported distributions"
	@echo "  $(GREEN)test-debian$(NC)          - Test all Debian-based distributions"
	@echo "  $(GREEN)test-rhel$(NC)            - Test all RHEL-based distributions"
	@echo "  $(GREEN)test-<distro>$(NC)        - Test specific distribution"
	@echo "  $(GREEN)lint$(NC)                 - Run linting (yamllint + ansible-lint)"
	@echo "  $(GREEN)syntax$(NC)               - Check Ansible syntax"
	@echo "  $(GREEN)check$(NC)                - Run syntax check and linting"
	@echo "  $(GREEN)clean$(NC)                - Clean up Molecule instances"
	@echo "  $(GREEN)install-deps-qemu$(NC)    - Install required dependencies for QEMU"
	@echo ""
	@echo "$(YELLOW)Supported distributions:$(NC)"
	@echo "  Debian family: $(DEBIAN_DISTROS)"
	@echo "  RHEL family:   $(RHEL_DISTROS)"
	@echo ""
	@echo "$(YELLOW)Environment variables:$(NC)"
	@echo "  MOLECULE_MEMORY=$(MOLECULE_MEMORY)   - Memory allocation for VMs"
	@echo "  MOLECULE_CPUS=$(MOLECULE_CPUS)     - CPU allocation for VMs"
	@echo "  MOLECULE_DISK=$(MOLECULE_DISK)     - Disk size for VMs"
	@echo "  MOLECULE_VERBOSE=$(MOLECULE_VERBOSE) - Enable verbose output"

# Install dependencies for QEMU
install-deps-qemu:
	@echo "$(YELLOW)Installing dependencies for molecule-qemu...$(NC)"
	pip install molecule-qemu molecule[ansible] ansible-lint yamllint
	@echo "$(YELLOW)Installing QEMU (platform-specific)...$(NC)"
	@if command -v brew >/dev/null 2>&1; then \
		echo "Installing QEMU on macOS..."; \
		brew install qemu cdrtools; \
	elif command -v apt-get >/dev/null 2>&1; then \
		echo "Installing QEMU on Ubuntu/Debian..."; \
		sudo apt-get update && sudo apt-get install -y mkisofs qemu-system-x86 qemu-utils; \
	elif command -v yum >/dev/null 2>&1; then \
		echo "Installing QEMU on RHEL/CentOS..."; \
		sudo yum install -y genisoimage qemu-kvm qemu-img; \
	else \
		echo "$(RED)Please install QEMU manually for your platform$(NC)"; \
	fi

# Default test (ubuntu2204)
test:
	@$(MAKE) test-ubuntu2204

# Test all distributions
test-all:
	@echo "$(YELLOW)Testing all distributions with QEMU...$(NC)"
	@for distro in $(ALL_DISTROS); do \
		echo "$(GREEN)Testing $$distro...$(NC)"; \
		$(MAKE) test-$$distro || (echo "$(RED)Test failed for $$distro$(NC)" && exit 1); \
	done
	@echo "$(GREEN)All tests passed!$(NC)"

# Individual distribution tests with cloud images
test-ubuntu2204:
	@echo "$(GREEN)Testing Ubuntu 22.04 with QEMU...$(NC)"
	MOLECULE_DISTRO=ubuntu2204 \
	MOLECULE_IMAGE_URL=https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img \
	MOLECULE_IMAGE_CHECKSUM=sha256:https://cloud-images.ubuntu.com/releases/22.04/release/SHA256SUMS \
	MOLECULE_SSH_USER=ubuntu MOLECULE_GROUP=debian_family \
	MOLECULE_MEMORY=$(MOLECULE_MEMORY) MOLECULE_CPUS=$(MOLECULE_CPUS) MOLECULE_DISK=$(MOLECULE_DISK) \
	molecule test

test-ubuntu2004:
	@echo "$(GREEN)Testing Ubuntu 20.04 with QEMU...$(NC)"
	MOLECULE_DISTRO=ubuntu2004 \
	MOLECULE_IMAGE_URL=https://cloud-images.ubuntu.com/releases/20.04/release/ubuntu-20.04-server-cloudimg-amd64.img \
	MOLECULE_IMAGE_CHECKSUM=sha256:https://cloud-images.ubuntu.com/releases/20.04/release/SHA256SUMS \
	MOLECULE_SSH_USER=ubuntu MOLECULE_GROUP=debian_family \
	MOLECULE_MEMORY=$(MOLECULE_MEMORY) MOLECULE_CPUS=$(MOLECULE_CPUS) MOLECULE_DISK=$(MOLECULE_DISK) \
	molecule test

test-debian12:
	@echo "$(GREEN)Testing Debian 12 with QEMU...$(NC)"
	MOLECULE_DISTRO=debian12 \
	MOLECULE_IMAGE_URL=https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2 \
	MOLECULE_IMAGE_CHECKSUM=sha512:https://cloud.debian.org/images/cloud/bookworm/latest/SHA512SUMS \
	MOLECULE_SSH_USER=debian MOLECULE_GROUP=debian_family \
	MOLECULE_MEMORY=$(MOLECULE_MEMORY) MOLECULE_CPUS=$(MOLECULE_CPUS) MOLECULE_DISK=$(MOLECULE_DISK) \
	molecule test

test-debian11:
	@echo "$(GREEN)Testing Debian 11 with QEMU...$(NC)"
	MOLECULE_DISTRO=debian11 \
	MOLECULE_IMAGE_URL=https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2 \
	MOLECULE_IMAGE_CHECKSUM=sha512:https://cloud.debian.org/images/cloud/bullseye/latest/SHA512SUMS \
	MOLECULE_SSH_USER=debian MOLECULE_GROUP=debian_family \
	MOLECULE_MEMORY=$(MOLECULE_MEMORY) MOLECULE_CPUS=$(MOLECULE_CPUS) MOLECULE_DISK=$(MOLECULE_DISK) \
	molecule test

test-rocky9:
	@echo "$(GREEN)Testing Rocky Linux 9 with QEMU...$(NC)"
	MOLECULE_DISTRO=rocky9 \
	MOLECULE_IMAGE_URL=https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2 \
	MOLECULE_IMAGE_CHECKSUM=sha256:https://download.rockylinux.org/pub/rocky/9/images/x86_64/CHECKSUM \
	MOLECULE_SSH_USER=rocky MOLECULE_GROUP=rhel_family \
	MOLECULE_MEMORY=$(MOLECULE_MEMORY) MOLECULE_CPUS=$(MOLECULE_CPUS) MOLECULE_DISK=$(MOLECULE_DISK) \
	molecule test

test-rocky8:
	@echo "$(GREEN)Testing Rocky Linux 8 with QEMU...$(NC)"
	MOLECULE_DISTRO=rocky8 \
	MOLECULE_IMAGE_URL=https://download.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud-Base.latest.x86_64.qcow2 \
	MOLECULE_IMAGE_CHECKSUM=sha256:https://download.rockylinux.org/pub/rocky/8/images/x86_64/CHECKSUM \
	MOLECULE_SSH_USER=rocky MOLECULE_GROUP=rhel_family \
	MOLECULE_MEMORY=$(MOLECULE_MEMORY) MOLECULE_CPUS=$(MOLECULE_CPUS) MOLECULE_DISK=$(MOLECULE_DISK) \
	molecule test

# Linting and syntax checking (same as before)
lint:
	@echo "$(YELLOW)Running linting...$(NC)"
	yamllint .
	ansible-lint

syntax:
	@echo "$(YELLOW)Checking Ansible syntax...$(NC)"
	ansible-playbook --syntax-check molecule/default/converge.yml
	ansible-playbook --syntax-check molecule/default/verify.yml

check: syntax lint
	@echo "$(GREEN)All checks passed!$(NC)"

# Cleanup
clean:
	@echo "$(YELLOW)Cleaning up Molecule instances...$(NC)"
	molecule cleanup
	molecule destroy