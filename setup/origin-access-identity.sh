#!/bin/bash
. ../variables.sh

echo "Uploading lambda zip for ${LAMBDA_BUCKET}"
mkdir -p lambdas/${NAME}/lib
pip install -r lambdas/${NAME}/requirements.txt -t lambdas/${NAME} --upgrade
cd lambdas/${NAME} && zip -r ../${NAME}.zip * && cd ../..

aws s3 cp "lambdas/${NAME}.zip" "s3://${LAMBDA_BUCKET}/"
version=`aws s3api list-object-versions --bucket ${LAMBDA_BUCKET} --prefix "${NAME}.zip" | jq -r .Versions[0].VersionId`
export LAMBDA_VERSION=$version
echo "The lambda version is: $LAMBDA_VERSION"

echo "Packaging cloudformation template..."
LONO_ENV=prod lono generate

echo "Uploading nested stacks to ${CLOUDFORMATION_BUCKET}"
aws s3 cp "output" "s3://${CLOUDFORMATION_BUCKET}/" --recursive
