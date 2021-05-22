import json
import boto3

def main(event, context):
    # TODO implement
    client = boto3.client('codecommit')
    response = client.create_repository(
    repositoryName='TestApp',
    repositoryDescription='Sample repo for testa'
    )
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
