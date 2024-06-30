# Define the lists of usernames and passwords
$usernames = @("user1", "user2", "user3")
$passwords = @("User1Pwd!", "User2Pwd", "User3Pwd")

# Ensure the lengths of both arrays match
if ($usernames.Count -ne $passwords.Count) {
    Write-Error "The number of usernames does not match the number of passwords."
    exit
}

# Ask the user if they want to create a new custom group
$groupChoice = Read-Host "Do you want to create a new custom group or add users to Power Users and Remote Desktop Users groups? Enter 'custom' for custom group, 'default' for  'Power Users  and Remote Desktop Users' groups"

if ($groupChoice -eq 'custom') {
    # Define the custom group name
    $customGroupName = Read-Host "Enter the name of the custom group"

    # Create the custom group if it does not exist
    if (-Not (Get-LocalGroup -Name $customGroupName -ErrorAction SilentlyContinue)) {
        try {
            New-LocalGroup -Name $customGroupName -Description "Custom user group"
            Write-Output "Group $customGroupName created successfully."
        } catch {
            Write-Error "Failed to create group $customGroupName: $_"
            exit
        }
    } else {
        Write-Output "Group $customGroupName already exists."
    }
}

# Loop through the arrays and create the users
for ($i = 0; $i -lt $usernames.Count; $i++) {
    $username = $usernames[$i]
    $password = $passwords[$i] | ConvertTo-SecureString -AsPlainText -Force

    try {
        New-LocalUser -Name $username -Password $password -FullName $username -Description "User $username" -UserMayNotChangePassword -PasswordNeverExpires
        Write-Output "User $username created successfully."

        if ($groupChoice -eq 'custom') {
            # Add user to Custom User Group
            Add-LocalGroupMember -Group $customGroupName -Member $username
            Write-Output "User $username added to $customGroupName group."
        } elseif ($groupChoice -eq 'default') {
            # Add user to Remote Desktop Users group
            Add-LocalGroupMember -Group "Remote Desktop Users" -Member $username
            Write-Output "User $username added to Remote Desktop Users group."

            # Add user to Power Users group
            Add-LocalGroupMember -Group "Power Users" -Member $username
            Write-Output "User $username added to Power Users group."
        }
    } catch {
        Write-Error "Failed to create user $username or add to groups: $_"
    }
}

Write-Output "All users processed."
