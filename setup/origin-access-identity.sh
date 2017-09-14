#!/bin/bash

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
