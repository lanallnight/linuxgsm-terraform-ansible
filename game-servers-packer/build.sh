#!/bin/bash

# Packer build script for LinuxGSM images
# Usage: ./build.sh [validate|build]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Variables file to use
VAR_FILE="variables.pkrvars.hcl"

# Check if variables file exists
if [ ! -f "$VAR_FILE" ]; then
    echo "❌ Error: Variables file not found: $VAR_FILE"
    echo "Please create $VAR_FILE with your Vultr API key:"
    echo "  vultr_api_key = \"your-vultr-api-key-here\""
    exit 1
fi

# Check if variables file contains API key
if ! grep -q "vultr_api_key" "$VAR_FILE"; then
    echo "❌ Error: vultr_api_key not found in $VAR_FILE"
    echo "Please add your API key to $VAR_FILE:"
    echo "  vultr_api_key = \"your-vultr-api-key-here\""
    exit 1
fi

echo "✅ Using variables file: $VAR_FILE"

# Default action is build
ACTION=${1:-build}

case $ACTION in
    "validate")
        echo "🔍 Validating Packer configuration..."
        packer validate --var-file="$VAR_FILE" images.pkr.hcl
        echo "✅ Configuration is valid!"
        ;;
    "build")
        echo "🚀 Starting Packer build..."
        echo "📦 Building LinuxGSM base image..."
        packer build --var-file="$VAR_FILE" images.pkr.hcl
        echo "✅ Build completed!"
        ;;
    *)
        echo "Usage: $0 [validate|build]"
        echo "  validate - Check configuration syntax"
        echo "  build    - Build the image (default)"
        exit 1
        ;;
esac