#!/bin/bash

#! Change directory to RDS-Backups:
cd "C:\Backup\RDS-Backups"

#! Prompt the user to choose an RDS endpoint
echo -e "Choose an RDS endpoint:\n1. database1 \n2. aws-rds-db1 \n3. awsrds-sbox-2020 \n4. aws-rds-prd1 "
read Choice

#! Set the endpoint and username based on the user's choice
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

#! Read the password for the chosen endpoint
echo -e "Enter the password for $Username:"
read -s Password
echo ""

#! Check Schemas:
echo -e "\nDo you want to check your schemas? [Y/N]"
read Choice
if [ "$Choice" == "y" ] || [ "$Choice" == "Y" ]; then
    mysql -u "$Username" -p"$Password" -h "$Endpoint" -e "SHOW SCHEMAS;"
elif [ "$Choice" == "n" ] || [ "$Choice" == "N" ]; then
    echo -e "okay...\n"
else
    echo -e "\nInvalid choice. Please enter 'y' or 'n'."
fi

#! Getting Schema to Backup:
echo -e "\nEnter the name of the schema you want to backup:\n"
read SchemaName

SchemaName = 1234


#! Validate if the entered schema name exists
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
            read SchemaName
        else
            echo "You have entered the wrong Schema name. Maximum attempts (3) reached. Exiting..."
            exit 1
        fi
    fi
done

#! Backup the schema
echo "Creating backup...\n"

BackupName="${SchemaName}_$(date +%Y%m%d_%H%M%S).sql"

echo "Creating backup: $BackupName"
mysqldump -u "$Username" -p"$Password" -h "$Endpoint" --single-transaction --progress="Status: --" --routines --triggers --events "$SchemaName" > "$BackupName" || {
    echo "Error creating backup. Exiting."
    exit 1
}


#! Post backup steps

if [ $? -eq 0 ]; then
    echo "\nBackup completed successfully."

    #? removing DEFINER clauses from dump.
    sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i "$BackupName" || {
        echo "Error removing DEFINER clauses from backup file. Exiting."
        exit 1
    }
    echo "DEFINER clauses removed."

    #? Zip the backup file in .7z format.
    7z a "${BackupName}.7z" "$BackupName" || {
        echo "Error zipping backup file. Exiting."
        exit 1
    }
    echo "Backup file zipped as ${BackupName}.7z"

    #? Upload the zipped file to S3 bucket.
    aws s3 cp "${BackupName}.7z" s3://readywire-rds-backup/ || {
        echo "Error uploading zipped backup file to S3. Exiting."
        exit 1
    }
    echo "Zipped backup file uploaded to s3://readywire-rds-backup"

    #? Generating pre-signed URL, valid for 1 days.
    pre_signed_url=$(aws s3 presign s3://you-bucket-name/"${BackupName}.7z" --expires-in 86400)
    echo "Download Link for backup (valid for 1 day) :$pre_signed_url"

else
    echo "Error creating backup. Exiting..."
    exit 1