#!/bin/bash

NAME="$1"
WORKING_DIR="$2"

if [[ -z "${WORKING_DIR}" ]]
then
  WORKING_DIR="."
fi

cd $WORKING_DIR

. variables.sh

#LONO_ENV=dev lono generate
#LONO_ENV=test lono generate

stackExists=`aws cloudformation list-stacks | jq -r "[.StackSummaries[] | select(.StackName == \"${NAME}\")] | .[0].StackStatus"`

function setUp() {

  echo "Uploading lambda zip for ${S3_BUCKET}"
  mkdir -p lambdas/cloudfront-origin-access-identity/lib
  pip install -r lambdas/cloudfront-origin-access-identity/requirements.txt -t lambdas/cloudfront-origin-access-identity --upgrade
  cd lambdas/cloudfront-origin-access-identity && zip -r ../pr52-lam-sad-cloudfrontoriginaccessidentity.zip * && cd ../..

  aws s3 cp "lambdas/pr52-lam-sad-cloudfrontoriginaccessidentity.zip" "s3://${S3_BUCKET}/SmallAppsDomain/lambda-source/"
  version=`aws s3api list-object-versions --bucket pgds-cross-account-access --prefix 'SmallAppsDomain/lambda-source/pr52-lam-sad-cloudfrontoriginaccessidentity.zip' | jq -r .Versions[0].VersionId`
  export LAMBDA_VERSION=$version
  echo "The lambda version is: $LAMBDA_VERSION"

  echo "Packaging cloudformation template..."
  LONO_ENV=prod lono generate

  echo "Uploading nested stacks to ${S3_BUCKET}"
  aws s3 cp "output" "s3://${S3_BUCKET}/SmallAppsDomain/" --recursive
  
}

function testIsValid() {
  echo "Testing the template is valid..."
  aws cloudformation validate-template --template-url "https://s3-${REGION}.amazonaws.com/${S3_BUCKET}/SmallAppsDomain/${NAME}.yml" 1> /dev/null

  if [[ $? -gt 0 ]]
  then
    exit 1
  fi

  sleep 5
}

function tidyUp() {
  echo "Tidying up!"
}


if [[ -z $stackExists ]] || [[ $stackExists == "DELETE_COMPLETE" ]] || [[ $stackExists == "null" ]]
then
  echo "Creating a new stack with name: ${NAME}"
  setUp
  testIsValid
  echo "Starting creation..."
  aws cloudformation create-stack \
  --template-url "https://s3-${REGION}.amazonaws.com/${S3_BUCKET}/SmallAppsDomain/${NAME}.yml" \
  --stack-name ${NAME} \
  --capabilities "CAPABILITY_NAMED_IAM" \
  --parameters file://${WORKING_DIR}/output/params/prod/${NAME}.json
elif [[ *"${stackExists}"* != "IN_PROGRESS" ]]
then
  echo "Updating the stack: ${NAME}"
  setUp
  testIsValid
  echo "Starting update... "
  aws cloudformation update-stack \
  --template-url "https://s3-${REGION}.amazonaws.com/${S3_BUCKET}/SmallAppsDomain/${NAME}.yml" \
  --stack-name ${NAME} \
  --capabilities "CAPABILITY_NAMED_IAM" \
  --parameters file://${WORKING_DIR}/output/params/prod/${NAME}.json
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
  #echo "Deleting stack: ${NAME}"
  #aws cloudformation delete-stack --stack-name ${NAME}
fi

tidyUp
