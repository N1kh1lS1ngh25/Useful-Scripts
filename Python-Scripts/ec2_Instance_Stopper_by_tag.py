################################################################################################
# EC2 Instance Stopper By Tag
# This AWS Lambda function stops EC2 instances based on a specific tag.
# The function looks for EC2 instances tagged with 'Name:Build-EC2' and stops them.
# It is designed to run as an AWS Lambda function.
################################################################################################
# Dependencies:
# - boto3: AWS SDK for Python
# - Logging: Standard Python logging library
################################################################################################
# Note: Ensure that the Lambda function has proper IAM permissions to describe and stop EC2 instances.
################################################################################################


import json
import boto3
import logging

# Create an EC2 client for your AWS region
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
        # Describe EC2 instances with a specific tag ('Name:Build-EC2')
        response = client.describe_instances(
            Filters=[{
                'Name': 'tag:Name',
                'Values': ['Build-EC2']
            }]
        )

        # Check if instances was found
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
        'body': json.dumps('This Lambda Function stops the Instances with Specific Tags')
    }
