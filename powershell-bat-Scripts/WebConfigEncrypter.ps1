#Fuction to display the current connection string:
function DisplayCurrentConnectionString {
    Write-Host "Current Connection String Details:" 
    
    write-Host "-----------------------------------------------------------------------------"
    $connectionString.connectionString.Split(';') | ForEach-Object {
        Write-Host $_
    }
   <#  Write-Host "Server: $($connectionString.connectionString.Split(';') | Where-Object {$_ -like 'Server=*'})"
    Write-Host "Database: $($connectionString.connectionString.Split(';') | Where-Object {$_ -like 'Database=*'})"
    Write-Host "Username: $($connectionString.connectionString.Split(';') | Where-Object {$_ -like 'Uid=*'})"
    write-host "Password: $($connectionString.connectionString.split(';') | Where-Object {$_ -like 'Pwd=*'})" #>
    write-Host "-----------------------------------------------------------------------------"
}


#Function to change current connection string:
function ChangeConnectionString {
    # Take input for new connection string values
    Write-Host "Enter new connection string values. To Keep current value. Press Enter" 
    write-Host "-----------------------------------------------------------------------------"
    $newServer = Read-Host "Enter new server address"
    $newDatabase = Read-Host "Enter new database name"
    $newUsername = Read-Host "Enter new username"
    $newPassword = Read-Host "Enter new password" -AsSecureString
    write-Host "-----------------------------------------------------------------------------"

    $newPasswordPlain = if ($newPassword) {
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($newPassword))
    }
    
    if ($newServer -or $newDatabase -or $newUsername -or $newPasswordPlain) {
        $newConnectionString = "Server=$($newServer);Database=$($newDatabase);Uid=$($newUsername);Pwd=$($newPasswordPlain);found rows=true;Unicode=true;"
        
        # Display new connection string 
        Write-Host "New Connection String Details:" 
        write-Host "-----------------------------------------------------------------------------"
        Write-Host "Server: $($newServer)"
        Write-Host "Database: $($newDatabase)"
        Write-Host "Username: $($newUsername)"
        Write-Host "Password: $($newPasswordPlain)"
        write-Host "-----------------------------------------------------------------------------"

        # Prompt user to confirm before saving changes
        $confirmation = Read-Host "Confirm if the details are correct and you want to update the connection string (yes/no)" 
        if ($confirmation -eq "yes") {
            # Update the connectionString property
            $connectionString.connectionString = $newConnectionString
            # Save the updated xml back to the file
            $xml.Save($configFilePath)
            Write-Host "Connection string updated successfully" 
        }
        else {
            Write-Host "Connection string update cancelled."
        }
    }
    else {
        Write-Host "Keeping current connection string data as new values were not provided."
    }
}


#Function for encrypting:
function Encryptcon{
    try {
        & aspnet_regiis.exe -pef connectionStrings "$rootDir"
    Write-Host "Connection String Encrypted" 
    write-Host "-----------------------------------------------------------------------------"
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Host "Error occurred while encrypting connection string: $_"
    }
}


#function for Decrypting:
function Decryptcon{
    try {
        & aspnet_regiis.exe -pdf connectionStrings "$rootDir"
        Write-Host "Connection String Decrypted" 
        write-Host "-----------------------------------------------------------------------------"
        
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Host "Error occurred while decrypting connection string: $_"
    }
}

#Function for giving options to user:
function question{
    write-Host "----------------------------------------------------------------------------- `n"
    switch (Read-Host "Choose from below options: `n [1] Display the current connection String data. `n [2] Update the current connection string. `n [3] Exit `n`n" ) {
            1 {
                DisplayCurrentConnectionString
                break
            }
            2 {
                ChangeConnectionString
                break
            }
            3 {
                exit
            }
        Default {
                write-Host "Please select an option:"
        }
    }   
}

<# function DecryptAndSetConnectionString {
    Decryptcon
    $connectionStrings = $xml.configuration.connectionStrings
    $connectionString = $connectionStrings.add | Where-Object {$_.name -eq 'ProjectX'}
} #>

#MAIN SCRIPT:


$rootDir = Read-Host "`n Enter the root directory of web.config `n" 
$configFilePath = Join-Path $rootDir -ChildPath "web.config"


 if (Test-Path $configFilePath){
    $xml = [xml](Get-Content $configFilePath)
        if($xml.configuration.connectionStrings){
            $connectionStrings = $xml.configuration.connectionStrings
            $connectionString = $connectionStrings.add | Where-Object {$_.name -eq 'ProjectX'}
            if ($connectionString) {
                Write-Host "`n Connection String not encrypted`n"
                question
                $ask1 = Read-Host "Do you want to Encrypt the connection string (yes/no)" 
                if ($ask1 -eq "yes") {
                    Encryptcon
                } else {
                    write-Host "Exiting the script....BYE-BYE :)"
                }
            } else {
                $ask = Read-Host "Do you want to decrypt the connection string (yes/no)" 
                if ($ask -eq "yes") {
                    Decryptcon
                    Write-Host "Exiting the script....BYE-BYE`n" 
                    Write-Host "Start the script again to view connection string or web.config file" 
                    <# $qu = Read-Host "Check Options (yes/no)"
                    if ($qu -eq "yes") {question}else{exit} #>
                } else {
                    write-Host "Exiting the script....BYE-BYE :)" 
                } 
            }
            
        }else{
            Write-Host "`n connectionStrings node not found in web.config file."
        }
}else {
    write-Host "`n Web.config file not found!"
}