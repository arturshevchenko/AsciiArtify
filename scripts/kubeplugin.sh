#!/bin/bash

# Kube plugin: Show resource usage per pod in a namespace
# Usage: kubectl resource-usage <namespace> <resource_type>

NAMESPACE="$1"
RESOURCE_TYPE="$2"

# Check for required parameters
if [[ -z "$NAMESPACE" || -z "$RESOURCE_TYPE" ]]; then
  echo "Usage: kubectl resource-usage <namespace> <resource_type>"
  exit 1
fi

# Validate if kubectl is installed
if ! command -v kubectl &> /dev/null; then
  echo "Error: kubectl not found. Please install kubectl first."
  exit 2
fi

# Get resource usage using kubectl top command
RESOURCE_OUTPUT=$(kubectl top "$RESOURCE_TYPE" -n "$NAMESPACE" 2>/dev/null)

if [[ $? -ne 0 ]]; then
  echo "Error: Failed to retrieve resource usage. Please check namespace and resource type."
  exit 3
fi

# Print header
echo "Resource,Namespace,Name,CPU,Memory"

# Process each line of output (skipping header)
echo "$RESOURCE_OUTPUT" | tail -n +2 | while read -r line; do
  NAME=$(echo "$line" | awk '{print $1}')
  CPU=$(echo "$line" | awk '{print $2}')
  MEMORY=$(echo "$line" | awk '{print $3}')
  echo "$RESOURCE_TYPE,$NAMESPACE,$NAME,$CPU,$MEMORY"
done
