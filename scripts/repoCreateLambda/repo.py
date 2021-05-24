import json
import boto3

def createRepo(appName):
    client = boto3.client('codecommit')
    response = client.create_repository(
    repositoryName=appName,
    repositoryDescription='Repo created for application '+appName
    )

    ssm = boto3.client('ssm')
    ssm_response = ssm.get_parameter(
        Name='/devops/lambda/connector/arn',
    )
    client.put_repository_triggers(
        repositoryName=appName,
        triggers=[
            {
                'name': 'connectorLambdaTrigger',
                'destinationArn': ssm_response['Parameter']['Value'],
                'branches': [],
                'events': [
                    'updateReference'
                ]
            },
        ]
    )

    return response

def updateTable(appName, appType, handler):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('productDB')
    table.put_item(
        Item= {
            "AppName" : appName,
            "AppType" : appType,
            "Handler" : handler
        }
    )

def main(event, context):
    try:
        handler = 'NA'
        appName = event['AppName']
        appType = event['AppType']
        if appType == 'lambda' :
            handler = event['Handler']
    except:
        putput = {
            'UserMessage' : "Required keys are not passed.",
        }
        return {
            'statusCode': 501,
            'body': json.dumps(output)
        }

    try:
        response = createRepo(appName)
    except:
        output =  {
            'UserMessage' : "A product with this name already exists.",
        }
        return {
            'statusCode': 501,
            'body': json.dumps(output)
        }

    try:
        repoUrl = response['repositoryMetadata']['cloneUrlHttp']
        updateTable(appName, appType, handler)
    except:
        client = boto3.client('codecommit')
        client.delete_repository(
            repositoryName='string'
        )
        output = {
            'UserMessage' : "There was an internal error, changes were reverted.",
        }
        return {
            'statusCode': 501,
            'body': json.dumps(output)
        }

    output = {
        'RepoUrl' : repoUrl,
    }
    return {
        'statusCode': 201,
        'body': json.dumps(output)
    }
