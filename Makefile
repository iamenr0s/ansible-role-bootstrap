# Makefile for Ansible Role Bootstrap Testing with molecule-qemu

# Default values
MOLECULE_MEMORY ?= 2048
MOLECULE_CPUS ?= 2
MOLECULE_DISK ?= 10G
MOLECULE_VERBOSE ?= false
MOLECULE_SSH_PORT ?= 2222

# Distribution-specific SSH ports
UBUNTU2204_SSH_PORT = 2223
UBUNTU2404_SSH_PORT = 2224
DEBIAN12_SSH_PORT = 2225
DEBIAN11_SSH_PORT = 2226
ROCKYLINUX10_SSH_PORT = 2227
ROCKYLINUX9_SSH_PORT = 2228
ALMALINUX10_SSH_PORT = 2229
ALMALINUX9_SSH_PORT = 2230
FEDORA42_SSH_PORT = 2231
FEDORA41_SSH_PORT = 2232

# Distribution configurations with cloud images
DEBIAN_DISTROS = ubuntu2404 ubuntu2204 debian12 debian11
RHEL_DISTROS = rockylinux10 rockylinux9 almalinux10 almalinux9 fedora42 fedora41
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
	@echo "  MOLECULE_NETWORK_SSH_PORT          - SSH port for VM (distribution-specific)"

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

test-ubuntu2404:
	@echo "$(GREEN)Testing Ubuntu 24.04 with QEMU...$(NC)"
	MOLECULE_DISTRO=ubuntu2404 \
	MOLECULE_IMAGE_URL=https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img \
	MOLECULE_IMAGE_CHECKSUM=sha256:https://cloud-images.ubuntu.com/releases/24.04/release/SHA256SUMS \
	MOLECULE_SSH_USER=ubuntu \
	MOLECULE_GROUP=debian_family \
	MOLECULE_NETWORK_SSH_PORT=$(UBUNTU2404_SSH_PORT) \
	MOLECULE_MEMORY=$(MOLECULE_MEMORY) MOLECULE_CPUS=$(MOLECULE_CPUS) MOLECULE_DISK=$(MOLECULE_DISK) \
	molecule -v test

test-ubuntu2204:
	@echo "$(GREEN)Testing Ubuntu 22.04 with QEMU...$(NC)"
	MOLECULE_DISTRO=ubuntu2204 \
	MOLECULE_IMAGE_URL=https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img \
	MOLECULE_IMAGE_CHECKSUM=sha256:https://cloud-images.ubuntu.com/releases/22.04/release/SHA256SUMS \
	MOLECULE_SSH_USER=ubuntu \
	MOLECULE_GROUP=debian_family \
	MOLECULE_NETWORK_SSH_PORT=$(UBUNTU2204_SSH_PORT) \
	MOLECULE_MEMORY=$(MOLECULE_MEMORY) MOLECULE_CPUS=$(MOLECULE_CPUS) MOLECULE_DISK=$(MOLECULE_DISK) \
	molecule -v test

test-debian12:
	@echo "$(GREEN)Testing Debian 12 with QEMU...$(NC)"
	MOLECULE_DISTRO=debian12 \
	MOLECULE_IMAGE_URL=https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2 \
	MOLECULE_IMAGE_CHECKSUM=sha512:https://cloud.debian.org/images/cloud/bookworm/latest/SHA512SUMS \
	MOLECULE_SSH_USER=debian \
	MOLECULE_GROUP=debian_family \
	MOLECULE_NETWORK_SSH_PORT=$(DEBIAN12_SSH_PORT) \
	MOLECULE_MEMORY=$(MOLECULE_MEMORY) MOLECULE_CPUS=$(MOLECULE_CPUS) MOLECULE_DISK=$(MOLECULE_DISK) \
	molecule -v test

test-debian11:
	@echo "$(GREEN)Testing Debian 11 with QEMU...$(NC)"
	MOLECULE_DISTRO=debian11 \
	MOLECULE_IMAGE_URL=https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2 \
	MOLECULE_IMAGE_CHECKSUM=sha512:https://cloud.debian.org/images/cloud/bullseye/latest/SHA512SUMS \
	MOLECULE_SSH_USER=debian \
	MOLECULE_GROUP=debian_family \
	MOLECULE_NETWORK_SSH_PORT=$(DEBIAN11_SSH_PORT) \
	MOLECULE_MEMORY=$(MOLECULE_MEMORY) MOLECULE_CPUS=$(MOLECULE_CPUS) MOLECULE_DISK=$(MOLECULE_DISK) \
	molecule -v test

test-rockylinux10:
	@echo "$(GREEN)Testing Rocky Linux 10 with QEMU...$(NC)"
	MOLECULE_DISTRO=rockylinux10 \
	MOLECULE_IMAGE_URL=https://download.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2 \
	MOLECULE_IMAGE_CHECKSUM=sha256:20e771c654724e002c32fb92a05fdfdd7ac878c192f50e2fc21f53e8f098b8f9 \
	MOLECULE_SSH_USER=rocky \
	MOLECULE_GROUP=rhel_family \
	MOLECULE_NETWORK_SSH_PORT=$(ROCKYLINUX10_SSH_PORT) \
	MOLECULE_MEMORY=$(MOLECULE_MEMORY) MOLECULE_CPUS=$(MOLECULE_CPUS) MOLECULE_DISK=$(MOLECULE_DISK) \
	molecule -v test

test-rockylinux9:
	@echo "$(GREEN)Testing Rocky Linux 9 with QEMU...$(NC)"
	MOLECULE_DISTRO=rockylinux9 \
	MOLECULE_IMAGE_URL=https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2 \
	MOLECULE_IMAGE_CHECKSUM=sha256:2c72815bb83cadccbede4704780e9b52033722db8a45c3fb02130aa380690a3d \
	MOLECULE_SSH_USER=rocky \
	MOLECULE_GROUP=rhel_family \
	MOLECULE_NETWORK_SSH_PORT=$(ROCKYLINUX9_SSH_PORT) \
	MOLECULE_MEMORY=$(MOLECULE_MEMORY) MOLECULE_CPUS=$(MOLECULE_CPUS) MOLECULE_DISK=$(MOLECULE_DISK) \
	molecule -v test

test-almalinux10:
	@echo "$(GREEN)Testing AlmaLinux 10 with QEMU...$(NC)"
	MOLECULE_DISTRO=almalinux10 \
	MOLECULE_IMAGE_URL=https://repo.almalinux.org/almalinux/10/cloud/x86_64/images/AlmaLinux-10-GenericCloud-latest.x86_64.qcow2 \
	MOLECULE_IMAGE_CHECKSUM=sha256:https://repo.almalinux.org/almalinux/10/cloud/x86_64/images/CHECKSUM \
	MOLECULE_SSH_USER=almalinux \
	MOLECULE_GROUP=rhel_family \
	MOLECULE_NETWORK_SSH_PORT=$(ALMALINUX10_SSH_PORT) \
	MOLECULE_MEMORY=$(MOLECULE_MEMORY) MOLECULE_CPUS=$(MOLECULE_CPUS) MOLECULE_DISK=$(MOLECULE_DISK) \
	molecule -v test

test-almalinux9:
	@echo "$(GREEN)Testing AlmaLinux 9 with QEMU...$(NC)"
	MOLECULE_DISTRO=almalinux9 \
	MOLECULE_IMAGE_URL=https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2 \
	MOLECULE_IMAGE_CHECKSUM=sha256:https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/CHECKSUM \
	MOLECULE_SSH_USER=almalinux \
	MOLECULE_GROUP=rhel_family \
	MOLECULE_NETWORK_SSH_PORT=$(ALMALINUX9_SSH_PORT) \
	MOLECULE_MEMORY=$(MOLECULE_MEMORY) MOLECULE_CPUS=$(MOLECULE_CPUS) MOLECULE_DISK=$(MOLECULE_DISK) \
	molecule -v test

test-fedora42:
	@echo "$(GREEN)Testing Fedora 42 with QEMU...$(NC)"
	MOLECULE_DISTRO=fedora42 \
	MOLECULE_IMAGE_URL=https://b4sh.mm.fcix.net/fedora/linux/releases/42/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-42-1.1.x86_64.qcow2 \
	MOLECULE_IMAGE_CHECKSUM=sha256:e401a4db2e5e04d1967b6729774faa96da629bcf3ba90b67d8d9cce9906bec0f \
	MOLECULE_SSH_USER=fedora \
	MOLECULE_GROUP=rhel_family \
	MOLECULE_NETWORK_SSH_PORT=$(FEDORA42_SSH_PORT) \
	MOLECULE_MEMORY=$(MOLECULE_MEMORY) MOLECULE_CPUS=$(MOLECULE_CPUS) MOLECULE_DISK=$(MOLECULE_DISK) \
	molecule -v test

test-fedora41:
	@echo "$(GREEN)Testing Fedora 41 with QEMU...$(NC)"
	MOLECULE_DISTRO=fedora41 \
	MOLECULE_IMAGE_URL=https://b4sh.mm.fcix.net/fedora/linux/releases/41/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-41-1.4.x86_64.qcow2 \
	MOLECULE_IMAGE_CHECKSUM=sha256:6205ae0c524b4d1816dbd3573ce29b5c44ed26c9fbc874fbe48c41c89dd0bac2 \
	MOLECULE_SSH_USER=fedora \
	MOLECULE_GROUP=rhel_family \
	MOLECULE_NETWORK_SSH_PORT=$(FEDORA41_SSH_PORT) \
	MOLECULE_MEMORY=$(MOLECULE_MEMORY) MOLECULE_CPUS=$(MOLECULE_CPUS) MOLECULE_DISK=$(MOLECULE_DISK) \
	molecule -v test

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
