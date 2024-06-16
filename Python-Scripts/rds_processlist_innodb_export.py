################################################################################################
# MySQL RDS Status Export Script:
# This script connects to an AWS RDS MySQL database, retrieves process list and InnoDB status information,
# saves them into CSV files, and uploads them to an S3 bucket for further analysis and monitoring
################################################################################################
# Usage:
# 1. Ensure AWS credentials are properly configured with permissions to access S3.
# 2. Set environment variables DB_UserID and DB_PASSWORD with MySQL credentials.
# 3. Update the host variable with the RDS endpoint.
################################################################################################
# Requirements:
# - Python 3
# - boto3 library (install via 'pip install boto3')
# - mysql-connector library (install via 'pip install mysql-connector-python')
# - AWS CLI configured or IAM role attached with necessary S3 permissions
################################################################################################


import boto3
import mysql.connector
from datetime import datetime, date
import os

# Database connection details
host = "databaseName.c17kchzxi7ws.region.rds.amazonaws.com"
user = os.environ.get("DB_UserID")
password = os.environ.get('DB_PASSWORD')

# Get current time and date for filenames
now = datetime.now()
time = now.strftime("%H-%M-%S") 
today = date.today()
date_str = today.strftime("%d-%m-%y")

# Filenames for output
process_list_file = f"ProcessList-{time}.csv"
innodb_status_file = f"InnoDBStatus-{time}.csv"

try:
    # Connect to the MySQL database
    connection = mysql.connector.connect(
        host=host,
        user=user,
        password=password
    )

    cursor = connection.cursor()

    try:
        # Execute SHOW FULL PROCESSLIST and write results to file
        cursor.execute("SHOW FULL PROCESSLIST")
        with open(process_list_file, "w") as file:
            file.write("SHOW FULL PROCESSLIST:\n")
            for result in cursor.fetchall():
                file.write(str(result) + "\n")

        # Execute SHOW ENGINE INNODB STATUS and write results to file
        cursor.execute("SHOW ENGINE INNODB STATUS")
        with open(innodb_status_file, "a") as file:
            file.write("\nSHOW ENGINE INNODB STATUS:\n")
            for result in cursor.fetchall():
                file.write(str(result) + "\n")

    finally:
        # Close the cursor and connection
        cursor.close()
        connection.close()

        # Uploading files to S3
        s3 = boto3.client("s3")
        bucket_name = "readywire-rdsoutputfiles"

        key1 = f"{date_str}/Process Lists/{process_list_file}"
        key2 = f"{date_str}/InnoDB Status/{innodb_status_file}"

        s3.upload_file(process_list_file, bucket_name, key1)
        s3.upload_file(innodb_status_file, bucket_name, key2)

except Exception as e:
    print(f"An error occurred: {str(e)}")