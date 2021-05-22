import json
import boto3
def find_codecommit_url(repo_name):
    client = boto3.client('codecommit')
    response = client.get_repository(
        repositoryName = repo_name
    )
    clone_url = response['repositoryMetadata']['cloneUrlHttp']
    return clone_url


def findAppType(appName):

def generateTfUrl(appType):


def main(event, context):
    repo_arn = event['Records']['eventSourceARN']
    repo_name = repo_arn.split(':')[-1]
    clone_url = find_codecommit_url(repo_name)

    return {
        'statusCode': 201,
        'body': json.dumps(output)
    }