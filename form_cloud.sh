#!/bin/bash

WORKING_DIR="$1"

if [[ -z "${WORKING_DIR}" ]]
then
  WORKING_DIR="."
fi

cd $WORKING_DIR

. variables.sh

lono generate

stackExists=`aws cloudformation list-stacks | jq -r "[.StackSummaries[] | select(.StackName == \"${STACK_NAME}\")] | .[0].StackStatus"`

function setUp() {
  echo "Packaging cloudformation template..."
  aws cloudformation package --template-file output/cloud.yaml --output-template export.yaml --s3-bucket ${S3_BUCKET}

  echo "Uploading cloud formation templates to S3..."
  currentDir=`pwd`
  cd ../cloudformation-templates && ./upload.sh && cd $currentDir

  pwd

  echo "Uploading template to S3 bucket..."
  aws s3 cp export.yaml "s3://${S3_BUCKET}/export.yaml"
}

function testIsValid() {
  echo "Testing the template is valid..."
  aws cloudformation validate-template --template-url "https://s3-${REGION}.amazonaws.com/${S3_BUCKET}/export.yaml" 1> /dev/null

  if [[ $? -gt 0 ]]
  then
    exit 1
  fi
}

function tidyUp() {
  #rm -f export.yaml
  echo "Tidying up!"
}


if [[ -z $stackExists ]] || [[ $stackExists == "DELETE_COMPLETE" ]]
then
  echo "Creating a new stack with name: ${STACK_NAME}"
  setUp
  testIsValid
  echo "Starting creation..."
  aws cloudformation create-stack \
  --template-url "https://s3-${REGION}.amazonaws.com/${S3_BUCKET}/export.yaml" \
  --stack-name ${STACK_NAME} \
  --capabilities "CAPABILITY_NAMED_IAM" \
  --parameters file://${WORKING_DIR}/output/params/params.json
elif [[ *"${stackExists}"* != "IN_PROGRESS" ]]
then
  echo "Updating the stack: ${STACK_NAME}"
  setUp
  testIsValid
  echo "Starting update..."
  aws cloudformation update-stack \
  --template-url "https://s3-${REGION}.amazonaws.com/${S3_BUCKET}/export.yaml" \
  --stack-name ${STACK_NAME} \
  --capabilities "CAPABILITY_NAMED_IAM" \
  --parameters file://${WORKING_DIR}/output/params/params.json
else
  echo "Work in progress, please try again later: ${stackExists}"
fi

exitStatus=`aws cloudformation list-stacks | jq -r "[.StackSummaries[] | select(.StackName == \"${STACK_NAME}\")] | .[0].StackStatus"`
echo "Status is: ${exitStatus}"
while [[ *"${exitStatus}"* == *"IN_PROGRESS"* ]]
do
  sleep 5
  exitStatus=`aws cloudformation list-stacks | jq -r "[.StackSummaries[] | select(.StackName == \"${STACK_NAME}\")] | .[0].StackStatus"`
  echo "Status is: ${exitStatus}"
  #aws cloudformation delete-stack --stack-name ${STACK_NAME}
done

if [[ ${exitStatus} == "ROLLBACK_COMPLETE" ]]
then
  echo "Failed to create or update stack!"
  echo "Downloading logs to ./logs directory"
  mkdir -p logs
  aws cloudformation describe-stacks --stack-name ${STACK_NAME} > logs/stack.log
  aws cloudformation describe-stack-events --stack-name ${STACK_NAME} > logs/stack-events.log
  echo "Downloaded logs:"
  ls ./logs
  echo "Deleting stack: ${STACK_NAME}"
  aws cloudformation delete-stack --stack-name ${STACK_NAME}
fi

tidyUp
