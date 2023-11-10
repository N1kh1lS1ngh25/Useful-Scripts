import json,boto3
client = boto3.client('ec2', region_name='ap-south-1')


def lambda_handler(event, context):
    # TODO implement
    response = client.describe_instances(
        Filters=[{
            'Name':'tag:Name',
            'Values':['Readywire-build-EC2']
        }]
        )
    # print(response["Reservations"][0]['Instances'][0]['InstanceId'])
    instance_id = response["Reservations"][0]['Instances'][0]['InstanceId']
    instances = [instance_id]
    response = client.stop_instances(InstanceIds=instances)
    print(response)
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
