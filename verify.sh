#!/bin/bash
# Verify cloudformation template, this check only work if you are relative
# to the project director ALA vagrant

PREFIX=$(dirname $0)
if [[ -f ${PREFIX}/variables.sh ]]; then
    . ${PREFIX}/variables.sh
else
    echo "Please configure variables.sh"
fi

TEMPLATE_PATH="nubis/cloudformation/main.json"

if [[ ! -f "${PROJECT_DIR}/${TEMPLATE_PATH}" ]]; then
    echo "Error: Cloudformation template does not exist"
    exit 1
fi

# XXX: Ugly!!!!!!! because mac/osx uses a different flag for sed
# we have to do this
PLATFORM=$(uname)
if [[ ${PLATFORM} == "Darwin" ]];
    SED_FLAG="-E"
else
    SED_FLAG="-r"
fi

echo -n "Validating: ${TEMPLATE_PATH} ... "
aws cloudformation validate-template --template-body file://$TEMPLATE_PATH > /dev/null 2>&1
RV=$?


if [[ ${RV} -ne 0 ]]; then
    echo "[FAILED]"
    echo -n "Error message: "
    aws cloudformation validate-template --template-body "file://${TEMPLATE_PATH}" 2>&1  | sed ${SED_FLAG} 's/^.+: .+: (.+)$/\1/g'
    exit ${RV}
else
    echo "[PASS]"
fi

