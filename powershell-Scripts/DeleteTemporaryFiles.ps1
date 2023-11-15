#########################################################################################################################################
# Script to delete temporary files from all user directories                                                                            #
# This script will recursively delete all temporary files in the AppData\Local\Temp directory for each user on the system               #
# Either run it manually or create a Cron job using windows inbuilt "Task Scheduler" to run the script at startup of the system.        #
#                                                                                                                                       #
# LICENSE:                                                                                                                              #
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files      #
# (the "Software"), to deal in the Software without restriction, including the rights to use, copy, modify, merge, publish, distribute, #
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the      #
# following conditions:                                                                                                                 #
#                                                                                                                                       #
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.        #
#                                                                                                                                       #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES       #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE       #
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR        #
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                                         #
##################################################################################################################################

# Define the path to the users directory
$profilesPath = "C:\Users"
#listing all the User directtory
$users = Get-ChildItem -Path $profilesPath -Directory
#Iterate over each user directory
foreach ($user in $users) {
# Create a temporary path to the 'AppData\Local\Temp' directory for the current user
    $tempPath = Join-Path -Path $user.FullName -ChildPath "AppData\Local\Temp"
 # Get a list of all files in the temporary directory 
    $files = Get-ChildItem -Path $tempPath -File -Recurse | Where-Object { -not $_.PSIsContainer }
    # Iterate over each file in the temporary directory
    foreach ($file in $files) {
        try {
         # Try to delete the file
            $file | Remove-Item -Force -ErrorAction Stop
        } catch {
        # If an error occurs, write a message to the console
            Write-Host "Error deleting file: $($file.FullName)"
        }
    }
}

	$scriptPath = "C:\Users\NikhilS\Desktop\DeleteTemporary.ps1"
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""
	  $trigger = New-ScheduledTaskTrigger -Daily -AtStartup
$settings = New-ScheduledTaskSettingsSet
$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings
Register-ScheduledTask -TaskName "TempDeleter" -TaskPath "\" -InputObject $Task -User "SYSTEM"

