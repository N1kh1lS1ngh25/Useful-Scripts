#!/bin/bash

# Configuration
BACKUP_DIR="C:\\Backup\\RDS-Backups"
S3_BUCKET="s3://readywire-rds-backup"
EXPIRES_IN=86400  # 1 day in seconds

# Change directory to RDS-Backups
cd "$BACKUP_DIR" || { echo "Failed to change directory to $BACKUP_DIR. Exiting..."; exit 1; }

# Prompt the user to choose an RDS endpoint
echo -e "Choose an RDS endpoint:\n1. database1 \n2. aws-rds-db1 \n3. awsrds-sbox-2020 \n4. aws-rds-prd1 "
read -r Choice

# Set the endpoint and username based on the user's choice
case $Choice in
    1)
        Endpoint="hostname1.c17kchzxi7ws.ap-south-1.rds.amazonaws.com"
        Username="rwadmin"
        ;;
    2)
        Endpoint="hostname-db.c17kchzxi7ws.ap-south-1.rds.amazonaws.com"
        Username="admin"
        ;;
    3)
        Endpoint="hostname1-sbox-.c17kchzxi7ws.ap-south-1.rds.amazonaws.com"
        Username="rdsadminsbox2020"
        ;;
    4)
        Endpoint="hostname1-prd.c17kchzxi7ws.ap-south-1.rds.amazonaws.com"
        Username="admin"
        ;;
    *)
        echo "Invalid choice. Exiting..."
        exit 1
        ;;
esac

# Read the password for the chosen endpoint
echo -e "Enter the password for $Username:"
read -rs Password
echo ""

# Check Schemas
echo -e "\nDo you want to check your schemas? [Y/N]"
read -r Choice
if [[ "$Choice" =~ ^[Yy]$ ]]; then
    mysql -u "$Username" -p"$Password" -h "$Endpoint" -e "SHOW SCHEMAS;"
elif [[ "$Choice" =~ ^[Nn]$ ]]; then
    echo -e "okay...\n"
else
    echo -e "\nInvalid choice. Please enter 'Y' or 'N'. Exiting..."
    exit 1
fi

# Getting Schema to Backup
echo -e "\nEnter the name of the schema you want to backup:"
read -r SchemaName

# Validate if the entered schema name exists
attempt=0
while [ "$attempt" -lt 3 ]; do
    schema_exists=$(mysql -u "$Username" -p"$Password" -h "$Endpoint" -e "SHOW DATABASES LIKE '$SchemaName';" | wc -l)
    if [ "$schema_exists" -eq 2 ]; then
        echo "Schema '$SchemaName' found."
        break
    else
        if [ "$attempt" -lt 2 ]; then
            echo "Schema '$SchemaName' does not exist. Please try again."
            attempt=$((attempt + 1))
            read -r SchemaName
        else
            echo "You have entered the wrong Schema name. Maximum attempts (3) reached. Exiting..."
            exit 1
        fi
    fi
done

# Backup the schema
echo "Creating backup...\n"
BackupName="${SchemaName}_$(date +%Y%m%d_%H%M%S).sql"

echo "Creating backup: $BackupName"
mysqldump -u "$Username" -p"$Password" -h "$Endpoint" --single-transaction --progress="Status: --" --routines --triggers --events "$SchemaName" > "$BackupName"
if [ $? -ne 0 ]; then
    echo "Error creating backup. Exiting..."
    exit 1
fi

# Post backup steps
echo "\nBackup completed successfully."

# Remove DEFINER clauses from dump
sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i "$BackupName"
if [ $? -ne 0 ]; then
    echo "Error removing DEFINER clauses from backup file. Exiting..."
    exit 1
fi
echo "DEFINER clauses removed."

# Zip the backup file in .7z format
7z a "${BackupName}.7z" "$BackupName"
if [ $? -ne 0 ]; then
    echo "Error zipping backup file. Exiting..."
    exit 1
fi
echo "Backup file zipped as ${BackupName}.7z"

# Upload the zipped file to S3 bucket
aws s3 cp "${BackupName}.7z" "$S3_BUCKET"
if [ $? -ne 0 ]; then
    echo "Error uploading zipped backup file to S3. Exiting..."
    exit 1
fi
echo "Zipped backup file uploaded to $S3_BUCKET"

# Generating pre-signed URL, valid for 1 day
pre_signed_url=$(aws s3 presign "$S3_BUCKET/${BackupName}.7z" --expires-in "$EXPIRES_IN")
echo "Download Link for backup (valid for 1 day): $pre_signed_url"
