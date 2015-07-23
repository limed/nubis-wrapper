#!/bin/bash
# SSH into your instance, this assumes your host is in us-west-2
# TODO: Dynamically figure out which region you can ssh to

# FIXME: make this dynamic
REGION="us-west-2"

PREFIX="$(dirname "$0")"
if [[ -f "${PREFIX}/variables.sh" ]]; then
    . "${PREFIX}/variables.sh"
else
    echo "Please configure variables.sh"
fi

# Name of the stack, only required value here
STACK_NAME="$1"

if [[ -z "${STACK_NAME}" ]]; then
    echo "Usage: $0 <stack name>"
    exit 1
fi

INSTANCE_OS=$(jq '.[]|.builders|.[]' ${PROJECT_DIR}/nubis/builder/project.json -r)

if [[ ${INSTANCE_OS} == "amazon-ebs-amazon-linux" ]]; then
    SSH_USERNAME="ec2-user"
elif [[ ${INSTANCE_OS} == "amazon-ebs-ubuntu" ]]; then
    SSH_USERNAME="ubuntu"
else
    echo "[Error]: Unknown OS type"
    exit 1
fi

# Get get-ec2-instance-ip, took this from nubis-consul script
# we do this so we don't have to depend on nubis-builder being around
get-ec2-instance-ip () {
    STACK_ID=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME --query 'StackResources[?LogicalResourceId == `EC2Stack`].PhysicalResourceId' --output text)
    AS_GROUP=$(aws cloudformation describe-stack-resources --stack-name $STACK_ID --query 'StackResources[?LogicalResourceId == `AutoScalingGroup`].PhysicalResourceId' --output text)
    INSTANCE_ID=$(aws autoscaling describe-auto-scaling-instances --query "AutoScalingInstances[?AutoScalingGroupName == \`$AS_GROUP\`].InstanceId" --output text)
    aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text
}

INSTANCE_IP=$(get-ec2-instance-ip)
if [[ -z "${INSTANCE_IP}" ]]; then
    echo "[Error]: Instance does not have an IP"
    exit 1
fi

# ssh to actual host, we assume jumphost will be an amazon linux instance
ssh -A -t ec2-user@jumphost1.sandbox.${REGION}.nubis.allizom.org "ssh -A -t ${SSH_USERNAME}@${INSTANCE_IP}"
