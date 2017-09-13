import json
import boto3
import cfnresponse

print('Loading function')
client = boto3.client('cloudfront')

def create_identity(event):
    response = client.create_cloud_front_origin_access_identity(
        CloudFrontOriginAccessIdentityConfig={
            'CallerReference': event['Reference'],
            'Comment': event['Comment']
        }
    )
    return response

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    success = True
    reason = None
    responseData = {}

    if event['RequestType'] == 'Create':
        try:
            response = create_identity(event)
            if response['CloudFrontOriginAccessIdentity'] is not None:
                success = True
                responseData['data'] = {
                    'id': response['CloudFrontOriginAccessIdentity']['Id'],
                    'S3CanonicalUserId': response['CloudFrontOriginAccessIdentity']['S3CanonicalUserId']
                }
            else:
                success = False
                reason = 'CREATE operation was not successful, no Origin Access Identity info in response'
        except:
            success = False
            reason = 'Origin Access Identity already exists for Reference ' + event['Reference']
    else:
        listIdentitiesResponse = client.list_cloud_front_origin_access_identities(
            MaxItems='999'
        )
        for item in listIdentitiesResponse['CloudFrontOriginAccessIdentityList']['Items']:
            identityInfo = client.get_cloud_front_origin_access_identity_config(
                Id=item['Id']
            )
            if identityInfo['CloudFrontOriginAccessIdentityConfig']['CallerReference'] == event['Reference']:
                if event['RequestType'] == 'Delete':
                    client.delete_cloud_front_origin_access_identity(
                        Id=item['Id'],
                        IfMatch=identityInfo['ETag']
                    )
                    success = True
                else:
                    updateResponse = client.update_cloud_front_origin_access_identity(
                        CloudFrontOriginAccessIdentityConfig={
                            'CallerReference': event['Reference'],
                            'Comment': event['Comment']
                        },
                        Id=item['Id'],
                        IfMatch=identityInfo['ETag']
                    )
                    if updateResponse['CloudFrontOriginAccessIdentity'] is not None:
                        success = True
                        responseData['data'] = {
                            'id': updateResponse['CloudFrontOriginAccessIdentity']['Id'],
                            'S3CanonicalUserId': updateResponse['CloudFrontOriginAccessIdentity']['S3CanonicalUserId']
                        }
                    else:
                        success = False
                        reason = 'Failed to UPDATE Origin Access Identity'
                break
    cfnresponse.send(event, context, cfnresponse.SUCCESS if success else cfnresponse.FAILED, responseData, 'origin-access-identity-' + event['ResourceProperties']['StackName'])
    print('Success: {}'.format(success))
    print('Reason: {}'.format(reason))
    print('Response: {}'.format(responseData))
