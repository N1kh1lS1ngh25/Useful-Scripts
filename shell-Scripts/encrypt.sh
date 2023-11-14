#!/usr/bin/bash

##########################################################################################################
# This script is designed to provide user-friendly interface for encrypting and decrypting files
# using "GNU Privacy guard (GPG)" utility.
#
# FEATURES:
# - Encrypts files with GPG symmetric encryption.
# - Decrypts GPG-encrypted files.
# - Option to specify custom names for encrypted/decrypted files.
# - Option to keep or remove the original file.
#
# USAGE:
# 1. Place this script in the same folder as the file you want to encrypt or decrypt.
# 2. Execute the script.
# 3. Choose whether to encrypt or decrypt a file.
#       - To encrypt: Provide the filename to be encrypted and a new name for the encrypted file.
#       - To decrypt: Provide the name of the encrypted file and a new name for the decrypted output.
# 4. For encryption, choose whether to keep or remove the original file.
#
# NOTE:
# - This script uses symmetric encryption, which means the same password is used for
#   encryption and decryption. Make sure to securely manage your passwords.
# - It does not manage GPG keys and uses the default behavior for symmetric encryption.
#
#
# Author: Nikhil Singh
# Version: 1.1
# Last Updated: 04-11-2023
###########################################################################################################

# Function to encrypt a file in the current directory
encrypt_file() {
    local file="$1"
    local new_filename="$2"

    #Encrypting the file and ouput the name of new file:
    gpg -c --output "${new_filename}.gpg" "$file"

    echo "$file" "Encrypted Successfully!!"
    echo "The encrypted file has been saved as: ${new_filename}.gpg"
    echo ""
    echo "Do you wish to remove the original file [Y/N]: "
    read rmove

    #Removing/keeping the original file as per user input:
    case "${rmove}" in
    y | Y)
        rm $file
        echo "Original file:" "$file" "removed,sucessfully!! "
        ;;
    n | N)
        echo "Original file not removed "
        ;;
    *)
        echo "Please choose form correct options"
        ;;
    esac
}

# Function to decrypt a file with .gpg extension present in the directory:
decrypt_file() {
    local encrypted_file="$1"
    local output_file="$2"

    gpg -d "$encrypted_file" >"$output_file"

    echo "File has been decrypted and saved as: $output_file"
}
echo ""
echo "#################################################"
echo "Welcome, I am ready to encrypt or decrypt a file."
echo "Please choose an option:"
echo ""
echo "1. Encrypt a file"
echo ""
echo "2. Decrypt a file"
echo ""
read -p "Enter your choice (1/2): " choice
echo "#################################################"
echo ""
case $choice in
1)
    echo ""
    echo "You have chosen to encrypt a file."
    sleep 1s
    echo "!NOTE! Place me in the same folder where a file to be encrypted is present."
    sleep 1s
    echo "Enter the Exact File Name with extension: "
    read -r file
    sleep 1s
    echo "Enter the name for the encrypted file (without extension): "
    read -r new_filename

    encrypt_file "$file" "$new_filename"
    ;;

2)
    echo ""
    echo "You have chosen to decrypt a file."
    sleep 1s
    echo "Please provide the name of the encrypted file (with .gpg extension):"
    read -r encrypted_file
    sleep 1s
    echo "Enter the name for the decrypted output file (without extension):"
    read -r output_file

    decrypt_file "$encrypted_file" "$output_file"
    ;;

*)
    echo "Invalid choice. Please choose from option 1 or 2."
    ;;
esac
