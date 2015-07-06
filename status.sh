#!/bin/bash
# View status of stack build

# Name of the stack, only required value here
STACK_NAME="$1"

if [[ -z "${STACK_NAME}" ]]; then
    echo "Usage: $0 <stack name>"
    exit 1
fi

watch -n 1 "echo 'Container Stack'; aws cloudformation describe-stacks --query 'Stacks[*].[StackName, StackStatus]' --output text --stack-name $STACK_NAME; echo \"\nNested Stacks\"; aws cloudformation describe-stack-resources --stack-name $STACK_NAME --query 'StackResources[*].[LogicalResourceId, ResourceStatus]' --output text"
