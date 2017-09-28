# origin-access-identity

Sets up a lambda that creates CloudFront origin access identities.

## Usage

Below is a massively simplified cloudformation template that demonstrates how to use this lambda in a custom resource and hook it into your S3 / CloudFormation configuration.

```
---
AWSTemplateFormatVersion: 2010-09-09
Description: 'Example usage for the origin-access-identity custom resource'

Parameters:
  CloudFrontOriginAccessIdentityResource:
    Description: The ARN for the resource which creates cloudfront origin access identities
    Type: String

Resources:
  ExampleBucket:
    Type: "AWS::S3::Bucket"
    Properties:
      AccessControl: PublicReadWrite
      BucketName: 'example-bucket'
  OriginAccessIdentity:
    Type: 'AWS::CloudFormation::CustomResource'
    Properties:
      ServiceToken: !Ref CloudFrontOriginAccessIdentityResource
      Reference: !Ref 'AWS::StackName'
      Comment: !Sub 'CloudFront origin access identity for: ${AWS::StackName}'
  OriginAccessIdentityPolicy:
    Type: 'AWS::S3::BucketPolicy'
    Properties:
      Bucket:
        Ref: ExampleBucket
      PolicyDocument:
        Statement:
          - Sid: 'AllowCloudFront'
            Effect: 'Allow'
            Principal:
              CanonicalUser: !GetAtt [OriginAccessIdentity, S3CanonicalUserId]
            Action: 's3:GetObject'
            Resource: !Join ['', ['arn:aws:s3:::', 'example-bucket', '/*']]
  ExampleCloudfront:
    Type: AWS::CloudFront::Distribution
    Properties:
        DistributionConfig:
          Comment: !Sub 'Cloudfront Distribution with an origin-access-identity'
          Origins:
          - DomainName: !Join ['.', ['example-bucket', 's3', 'amazonaws', 'com']]
            Id: S3Origin
            S3OriginConfig:
              OriginAccessIdentity: !Join ['/', ['origin-access-identity', 'cloudfront', !GetAtt [OriginAccessIdentity, Id]]]
            Enabled: true
            HttpVersion: 'http2'
            DefaultRootObject: 'index.html'
            Aliases:
              - !Join ['.', ['example', 'com']]
              - !Join ['.', ['www', 'example', 'com']]
            DefaultCacheBehavior:
              AllowedMethods:
              - GET
              - HEAD
              Compress: true
              TargetOriginId: S3Origin
              ForwardedValues:
                QueryString: true
                Cookies:
                  Forward: none
              ViewerProtocolPolicy: allow-all
            PriceClass: PriceClass_All
```
