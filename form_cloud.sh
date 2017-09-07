#!/bin/bash

NAME="$1"
WORKING_DIR="$2"

if [[ -z "${WORKING_DIR}" ]]
then
  WORKING_DIR="."
fi

cd $WORKING_DIR

. variables.sh

lono generate

stackExists=`aws cloudformation list-stacks | jq -r "[.StackSummaries[] | select(.StackName == \"${NAME}\")] | .[0].StackStatus"`

function setUp() {
  echo "Packaging cloudformation template..."
  aws cloudformation package --template-file output/${NAME}.yml --output-template export-${NAME}.yml --s3-bucket ${S3_BUCKET}

  echo "Uploading nested stacks to ${S3_BUCKET}"
  aws s3 cp output/stacks "s3://${S3_BUCKET}/stacks" --recursive

  echo "Uploading template to S3 bucket..."
  aws s3 cp export-${NAME}.yml "s3://${S3_BUCKET}/export-${NAME}.yml"
}

function testIsValid() {
  echo "Testing the template is valid..."
  aws cloudformation validate-template --template-url "https://s3-${REGION}.amazonaws.com/${S3_BUCKET}/export-${NAME}.yml" 1> /dev/null

  if [[ $? -gt 0 ]]
  then
    exit 1
  fi
}

function tidyUp() {
  echo "Tidying up!"
  rm -f export-${NAME}.yml
}


if [[ -z $stackExists ]] || [[ $stackExists == "DELETE_COMPLETE" ]] || [[ $stackExists == "null" ]]
then
  echo "Creating a new stack with name: ${NAME}"
  setUp
  testIsValid
  echo "Starting creation..."
  aws cloudformation create-stack \
  --template-url "https://s3-${REGION}.amazonaws.com/${S3_BUCKET}/export-${NAME}.yml" \
  --stack-name ${NAME} \
  --capabilities "CAPABILITY_NAMED_IAM"
elif [[ *"${stackExists}"* != "IN_PROGRESS" ]]
then
  echo "Updating the stack: ${NAME}"
  setUp
  testIsValid
  echo "Starting update... "
  aws cloudformation update-stack \
  --template-url "https://s3-${REGION}.amazonaws.com/${S3_BUCKET}/export-${NAME}.yml" \
  --stack-name ${NAME} \
  --capabilities "CAPABILITY_NAMED_IAM"
else
  echo "Work in progress, please try again later: ${stackExists}"
fi

exitStatus=`aws cloudformation list-stacks | jq -r "[.StackSummaries[] | select(.StackName == \"${NAME}\")] | .[0].StackStatus"`
echo "Status is: ${exitStatus}"
while [[ *"${exitStatus}"* == *"IN_PROGRESS"* ]]
do
  sleep 20
  exitStatus=`aws cloudformation list-stacks | jq -r "[.StackSummaries[] | select(.StackName == \"${NAME}\")] | .[0].StackStatus"`
  echo "Status is: ${exitStatus}"
  #aws cloudformation delete-stack --stack-name ${NAME}
done

if [[ ${exitStatus} == "ROLLBACK_COMPLETE" ]]
then
  echo "Failed to create or update stack!"
  echo "Downloading logs to ./logs directory"
  mkdir -p logs
  aws cloudformation describe-stacks --stack-name ${NAME} > logs/stack.log
  aws cloudformation describe-stack-events --stack-name ${NAME} > logs/stack-events.log
  echo "Downloaded logs:"
  ls ./logs
  echo "Deleting stack: ${NAME}"
  aws cloudformation delete-stack --stack-name ${NAME}
fi

tidyUp
