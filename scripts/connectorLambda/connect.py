import json
import boto3
def find_codecommit_url(repo_name):
    client = boto3.client('codecommit')
    response = client.get_repository(
        repositoryName = repo_name
    )
    clone_url = response['repositoryMetadata']['cloneUrlHttp']
    return clone_url

def readSsmParameter(key):
    ssm = boto3.client('ssm')
    ssm_response = ssm.get_parameter(
        Name=key,
    )
    value = ssm_response['Parameter']['Value']
    return value

def findAppType(appName):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('productDB')
    response = table.get_item(Key={'AppName': appName })
    appType = response['Item']['AppType']
    return appType

def generateTfUrl(appType):
    urlMap = {
        "container" : "https://dummy-container-repo.test/asd.git",
        "lambda"    : "https://dummy-container-repo.test/asd.git"
    }
    return urlMap[appType]

def sendDataToQueue(url, val):
    client = boto3.client('sqs')
    client.send_message(
        QueueUrl = url,
        MessageBody = val,
    )

def writeToSqs(data, appType):
    build_sqs_url = readSsmParameter('/devops/sqs/build/url')
    deploy_sqs_url = readSsmParameter('/devops/sqs/deploy/url')
    if appType == 'container':
        sendDataToQueue(build_sqs_url, json.dumps(data))
    elif appType == 'lambda':
        sendDataToQueue(deploy_sqs_url, json.dumps(data))

def main(event, context):
    repo_arn = event['Records'][0]['eventSourceARN']
    repo_name = repo_arn.split(':')[-1]
    clone_url = find_codecommit_url(repo_name)
    appType = findAppType(repo_name)
    tfScriptUrl = generateTfUrl(appType)
    bucketName = readSsmParameter('/devops/s3/backend/name')
    data = {
        "CloneUrl" : clone_url,
        "TfScriptUrl" : tfScriptUrl,
        "AppName" : repo_name,
        "TfBackendBucket" : bucketName,
        "TfBackendBucketPath" : "deploy/"+repo_name
    }
    writeToSqs(data, appType)

    return data