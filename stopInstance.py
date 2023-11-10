import json
import boto3
import logging

# Create an EC2 client for the specified AWS region
client = boto3.client('ec2', region_name='ap-south-1')

# Configure logging
logging.basicConfig(level=logging.INFO)

def lambda_handler(event, context):
    """
    Lambda function handler to stop EC2 instances based on a specific tag.

    Parameters:
    - event: Event data passed to the Lambda function.
    - context: Runtime information provided by Lambda.

    Returns:
    - dict: Response containing the status code and a message.
    """

    try:
        # Describe EC2 instances with a specific tag ('Name:Readywire-build-EC2')
        response = client.describe_instances(
            Filters=[{
                'Name': 'tag:Name',
                'Values': ['Readywire-build-EC2']
            }]
        )

        # Check if instances were found
        if response['Reservations']:
            instance_id = response["Reservations"][0]['Instances'][0]['InstanceId']

            # Create a list of instance IDs to stop
            instances_to_stop = [instance_id]

            # Stop the specified EC2 instances
            stop_response = client.stop_instances(InstanceIds=instances_to_stop)
            logging.info(f"Stop Instances Response: {stop_response}")
        else:
            logging.info("No instances found with the specified tag.")

    except Exception as e:
        # Log any errors
        logging.error(f"An error occurred: {str(e)}")

    # Return a response for the Lambda function
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
