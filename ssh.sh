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

INSTANCE_IP=$(nubis-consul --stack-name ${STACK_NAME} --settings ${PROJECT_DIR}/nubis/cloudformation/parameters.json get-ec2-instance-ip)
if [[ -z "${INSTANCE_IP}" ]]; then
    echo "[Error]: Instance does not have an IP"
    exit 1
fi

# ssh to actual host, we assume jumphost will be an amazon linux instance
ssh -A -t ec2-user@jumphost.sandbox.${REGION}.nubis.allizom.org "ssh -A -t ${SSH_USERNAME}@${INSTANCE_IP}"
