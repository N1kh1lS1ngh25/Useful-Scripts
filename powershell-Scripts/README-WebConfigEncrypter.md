# PowerShell Connection String Management Script
View [Script](https://github.com/N1kh1lS1ngh25/Useful-Scripts/blob/main/powershell-Scripts/WebConfigEncrypter.ps1)

This PowerShell script is designed to manage connection strings in a web.config file, primarily focusing on the connection string named 'ProjectX'. Here's a gist of what the script does:

## 1. Display Current Connection String (`DisplayCurrentConnectionString`):

This function is responsible for displaying the details of the current connection string. It achieves this by:

- Printing a header indicating that it's displaying the current connection string details.
- Splitting the connection string by semicolons and iterating over each part to display them individually.
- Commented out sections suggest an alternative approach to display specific parts of the connection string such as server address, database name, username, and password.

## 2. Change Connection String (`ChangeConnectionString`):

This function allows the user to update the connection string with new values. Here's how it works:

- Prompts the user to input new values for the server address, database name, username, and password.
- It securely prompts for the password using `-AsSecureString` to avoid plaintext password exposure.
- Converts the secure password into plain text for ease of use.
- Constructs a new connection string using the provided inputs.
- Displays the new connection string details and prompts the user to confirm if they want to update the connection string.
- If confirmed, it updates the connection string in the XML configuration and saves it back to the web.config file.

## 3. Encrypt and Decrypt Connection String (`Encryptcon` and `Decryptcon`):

These functions handle the encryption and decryption of the connection string using `aspnet_regiis.exe`. Here's a breakdown:

### Encryptcon:

- Attempts to encrypt the connection string.
- If successful, it displays a message indicating that the connection string is encrypted.
- If an error occurs during encryption, it catches the exception and displays an error message.

### Decryptcon:

- Tries to decrypt the connection string.
- Upon successful decryption, it notifies the user that the connection string is decrypted.
- In case of an error during decryption, it catches the exception and displays an error message.

## 4. Main Script Flow:

The main script follows these steps:

- Asks the user to input the root directory of the web.config file.
- Checks if the web.config file exists.
- If the file exists, it reads its content as XML.
- Checks if the `connectionStrings` node exists within the configuration.
- If the node exists, it tries to find the connection string named 'ProjectX'.
- Depending on whether the connection string is found or not, it prompts the user to either update, encrypt, or decrypt the connection string.
- If the web.config file or the `connectionStrings` node is not found, it displays appropriate messages.

## 5. User Interaction (`question` function):

The `question` function provides a structured menu for user interaction, offering options to display the current connection string, update it, or exit the script. It ensures a user-friendly experience by guiding the user through the available actions.

Overall, this script offers a comprehensive solution for managing connection strings in a web.config file, providing options for viewing, updating, encrypting, and decrypting the connection string while maintaining a clear and intuitive user interface.
