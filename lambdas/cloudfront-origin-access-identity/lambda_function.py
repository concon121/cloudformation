import json
import boto3

print('Loading function')


def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    client = boto3.client('cloudfront')
    response = client.create_cloud_front_origin_access_identity(
        CloudFrontOriginAccessIdentityConfig = {
            'CallerReference': event['ref'],
            'Comment': event['comment']
        }
    )
    return response  # Echo back the first key value
    #raise Exception('Something went wrong')
