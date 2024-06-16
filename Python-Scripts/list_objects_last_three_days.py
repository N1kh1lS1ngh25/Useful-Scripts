#                                      ________  
# _____ __  _  ________           _____\_____  \ 
# \__  \\ \/ \/ /  ___/  ______  /  ___/ _(__  < 
#  / __ \\     /\___ \  /_____/  \___ \ /       \
# (____  /\/\_//____  >         /____  >______  /
#      \/           \/               \/       \/
###############################################################################################
# This script lists objects in an S3 bucket that have been modified in the last three days.
# It handles large datasets by using pagination and includes error handling for common issues
# such as missing or incomplete AWS credentials and invalid bucket names.
###############################################################################################
# Usage:
# - Ensure you have AWS credentials configured properly.
# - Specify the S3 bucket name and folder prefix.
# - The script will output the key and last modified date of each object that meets the criteria.
################################################################################################
# Requirements:
# - boto3: AWS SDK for Python. Install using `pip install boto3`
# - AWS credentials: Ensure you have AWS credentials configured properly. This can be done by:
#   - Setting up `~/.aws/credentials` file
#   - Setting environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
################################################################################################


import boto3
from datetime import datetime, timedelta
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError

def list_objects_in_last_three_days(bucket_name, folder_prefix):
    s3 = boto3.client("s3")
    three_days_ago = datetime.now() - timedelta(days=3)
    paginator = s3.get_paginator('list_objects_v2')

    try:
        page_iterator = paginator.paginate(Bucket=bucket_name, Prefix=folder_prefix)
        objects_within_three_days = []

        for page in page_iterator:
            if 'Contents' in page:
                for obj in page['Contents']:
                    if obj['LastModified'].replace(tzinfo=None) >= three_days_ago:
                        objects_within_three_days.append(obj)

        sorted_objects = sorted(objects_within_three_days, key=lambda x: x['LastModified'])

        for obj in sorted_objects:
            print(f"Object: {obj['Key']}, Last Modified: {obj['LastModified']}")

    except NoCredentialsError:
        print("Error: No AWS credentials found.")
    except PartialCredentialsError:
        print("Error: Incomplete AWS credentials found.")
    except ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchBucket':
            print(f"Error: The bucket '{bucket_name}' does not exist.")
        else:
            print(f"Error: {e.response['Error']['Message']}")

# Example usage
bucket_name = "your-bucket-name"
folder_prefix = "Path/prefix/as/per/our/requirment/"
list_objects_in_last_three_days(bucket_name, folder_prefix)
