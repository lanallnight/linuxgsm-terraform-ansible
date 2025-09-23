#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 <command> <tfvars_file>"
    echo "Commands: test | plan | apply | destroy | output"
    exit 1
}

# Function to switch workspace and list workspaces
switch_workspace() {
    local workspace_name=$1
    echo "List of Workspaces:"
    terraform workspace list
    echo "Current Workspace:"
    terraform workspace show
    echo "Switching to Workspace: $workspace_name"
    terraform workspace new "$workspace_name" 2>/dev/null || terraform workspace select "$workspace_name"
    echo "Planned Workspace:"
    terraform workspace show
}

# Check if correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    usage
fi

# Assigning command and tfvars file arguments
command=$1
tfvars_file=$2

# Appending .tfvars extension if not provided
if [[ ! $tfvars_file == *".tfvars" ]]; then
    tfvars_file="$tfvars_file.tfvars"
fi

# Validate command
if [ "$command" != "test" ] && [ "$command" != "plan" ] && [ "$command" != "apply" ] && [ "$command" != "destroy" ] && [ "$command" != "output" ]; then
    echo "Invalid command."
    usage
fi

# Validate tfvars file
if [ ! -f "tfvars/$tfvars_file" ]; then
    echo "TFVars file not found."
    usage
fi

# Function to apply Terraform
apply_terraform() {
    # Execute Terraform command with auto-approve for apply and destroy
    if [ "$command" == "apply" ] || [ "$command" == "destroy" ]; then
        echo "Executing Terraform $command with auto-approve..."
        terraform "$command" -var-file="tfvars/$tfvars_file" -auto-approve
    else
        echo "Executing Terraform $command..."
        terraform "$command" -var-file="tfvars/$tfvars_file"
    fi
}

# Function to show Terraform output
show_terraform_output() {
    echo "Terraform Output:"
    terraform output
}

# Function to run Terraform test for the specified command
run_terraform_test() {
    echo "Running Terraform $command test..."
    
    # Test for Terraform command
    if [ "$command" == "output" ]; then
        show_terraform_output || { echo "Terraform $command failed."; exit 1; }
    else
        apply_terraform || { echo "Terraform $command failed."; exit 1; }
    fi
    
    echo "Terraform $command test passed successfully."
}

# Main script logic
cd "$(dirname "$0")" || exit

# Ensure Terraform is initialized
terraform init

# Switch workspace and list workspaces based on tfvars file name
workspace_name="${tfvars_file%.*}"
switch_workspace "$workspace_name"

# Execute Terraform test for the specified command
run_terraform_test
