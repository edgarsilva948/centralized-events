#!/usr/bin/env bash
# Stack bucket 
DEST_BUCKET='centralized-events'

# Stack region
REGION='us-east-1'

# HUB account environment variables
HUB_PARAM_FILE='hub-account.json'
HUB_ACCOUNT_STACK_NAME='hub-events'
HUB_ACCOUNT_TEMPLATE_FILE='hub-account.yaml'

# SPOKEN account environment variables
SPOKEN_PARAM_FILE='spoken-account.json'
SPOKEN_ACCOUNT_STACK_NAME='spoke-events'
SPOKEN_ACCOUNT_TEMPLATE_FILE='spoke-account.yaml'

echo "Setting the destination bucket to: " $DEST_BUCKET

if [ ! -d "output" ]
  then
  echo "Creating output directory"
  mkdir output
fi

if [ "$1" == "hub-account" ]
  then
    echo 'Building the template stack'
    aws cloudformation package \
        --region $REGION \
        --template-file templates/${HUB_ACCOUNT_TEMPLATE_FILE} \
        --s3-bucket $DEST_BUCKET \
        --output-template-file output/${HUB_ACCOUNT_TEMPLATE_FILE}
    echo 'Deploying the stack in the HUB Account'
    aws cloudformation deploy \
        --region $REGION \
        --template-file output/${HUB_ACCOUNT_TEMPLATE_FILE} \
        --capabilities CAPABILITY_NAMED_IAM \
        --s3-bucket ${DEST_BUCKET} \
        --parameter-overrides \
        $(jq -r '.Parameters | keys[] as $k | "\($k)=\(.[$k])"' parameters/${HUB_PARAM_FILE}) \
        --stack-name ${HUB_ACCOUNT_STACK_NAME}
elif [ "$1" == "spoke-account" ]
  then
    echo 'Building the template stack'
    aws cloudformation package \
        --region $REGION \
        --template-file templates/${SPOKE_ACCOUNT_TEMPLATE_FILE} \
        --s3-bucket $DEST_BUCKET \
        --output-template-file output/${SPOKE_ACCOUNT_TEMPLATE_FILE}
    echo 'Deploying the stack in the Spoke Account'
    aws cloudformation deploy \
        --region $REGION \
        --template-file output/${SPOKE_ACCOUNT_TEMPLATE_FILE} \
        --capabilities CAPABILITY_NAMED_IAM \
        --s3-bucket ${DEST_BUCKET} \
        --parameter-overrides \
        $(jq -r '.Parameters | keys[] as $k | "\($k)=\(.[$k])"' parameters/${SPOKE_PARAM_FILE}) \
        --stack-name ${SPOKE_ACCOUNT_STACK_NAME}
else
    echo "Please specify the account (HUB/Spoken)"
fi
