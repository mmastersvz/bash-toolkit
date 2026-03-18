#!/usr/bin/env bash
# simple inventory of current subscription (most common case)

set -euo pipefail

# Check if jq is installed (required for CSV conversion)
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed."
    echo "Please install it:"
    echo "  - macOS:     brew install jq"
    echo "  - Ubuntu/Debian: sudo apt update && sudo apt install jq"
    echo "  - Fedora:    sudo dnf install jq"
    echo "  - Windows (WSL/Git Bash): same as above or use chocolatey/scoop"
    exit 1
fi

# Interactive subscription selection
echo "Available subscriptions:"
az account list --query '[].{Name:name, ID:id, State:state}' --output table

read -p "Enter the exact Subscription NAME to use: " SUB_NAME

# Set the subscription
az account set --subscription "$SUB_NAME"

CURRENT_SUB=$(az account show --query 'name' -o tsv)
echo "Using subscription: $CURRENT_SUB"

# Output file with timestamp
output_file="azure_inventory_${CURRENT_SUB// /_}_$(date +%Y%m%d_%H%M%S).csv"

echo "Generating inventory..."

az resource list \
  --query '[].{Name:name, Type:type, ResourceGroup:resourceGroup, Location:location, SubscriptionId:subscriptionId, ID:id}' \
  --output json \
| jq -r '(.[0] | keys_unsorted | join(",")),
         (.[] | [.[]] | join(","))' > "$output_file"

# Quick stats
if [ -s "$output_file" ]; then
    line_count=$(wc -l < "$output_file")
    resource_count=$((line_count - 1))  # subtract header
    echo "Done. Found $resource_count resources."
    echo "Inventory saved to: $output_file"
    echo "First few lines for preview:"
    head -n 5 "$output_file"
else
    echo "Warning: Output file is empty. Check permissions or if jq processed correctly."
fi
