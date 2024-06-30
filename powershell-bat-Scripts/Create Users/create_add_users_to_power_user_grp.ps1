# Define the lists of usernames and passwords
$usernames = @("user1", "user2", "user3")
$passwords = @("User1Pwd!" , "User2Pwd","User3Pwd" )

# Ensure the lengths of both arrays match
if ($usernames.Count -ne $passwords.Count) {
    Write-Error "The number of usernames does not match the number of passwords."
    exit
}

# Loop through the arrays and create the users
for ($i = 0; $i -lt $usernames.Count; $i++) {
    $username = $usernames[$i]
    $password = $passwords[$i] | ConvertTo-SecureString -AsPlainText -Force

    try {
        New-LocalUser -Name $username -Password $password -FullName $username -Description "User $username" -UserMayNotChangePassword -PasswordNeverExpires
        Write-Output "User $username created successfully."

        # Add user to Remote Desktop Users group
        Add-LocalGroupMember -Group "Remote Desktop Users" -Member $username
        Write-Output "User $username added to Remote Desktop Users group."
 
        # Add user to Power Users group
        Add-LocalGroupMember -Group "Power Users" -Member $username
        Write-Output "User $username added to Power Users group."
    } catch {
        Write-Error "Failed to create user $username or add to groups: $_"
    }
}

Write-Output "All users processed."