#!/bin/bash
set -e

echo "==================================="
echo "Destroying Infrastructure with Terraform"
echo "==================================="

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
    echo "Error: Terraform not initialized. Run './deploy.sh' first or 'terraform init'."
    exit 1
fi

# Show what will be destroyed
echo "Planning destruction..."
terraform plan -destroy

# Destroy with auto-approve
echo "Destroying infrastructure..."
terraform destroy -auto-approve

echo ""
echo "==================================="
echo "Destruction Complete!"
echo "==================================="
echo "All Terraform-managed resources have been removed."
