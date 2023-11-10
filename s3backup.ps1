#######################################################################################################################################
#                                                                                                                                      #
# The motive of this script was to automate the Backup of .zip package customization created everyday.                                  #
# In this script package customization are created using Acumatica 'PX.CommandLine.exe'                                                 #
# once the package customization is created it will be moved to a local directory, which will be named in " <DD-MM-YYY>-<count>" format,#      
# Where <count> represents number of times the local directory is created( to mark the difference between each customization .zip).     #
# Files from local directory is then pasted to s3 bucket (Remeber to configure valid Access Key ID and Secret Access Key)               #
#                                                                                                                                       #
########################################################################################################################################

Write-Host "Starting script..."

Write-Host "Creating package Customization"

# "C:\Program Files\Acumatica ERP\rwdev22r2\Bin\PX.CommandLine.exe" is my location of PX.CommandLine.exe, in your system it might be different do check once.
# /in- Insert path where you Acumatica Dlls are saved
# /out- Insert path where you want the .zips to be saved

& "C:\Program Files\Acumatica ERP\rwdev22r2\Bin\PX.CommandLine.exe" /method BuildProject /in "C:\Acumatica Packages\2022R2\RWPackages\RW.Base.22.210.0020" /out "C:\DailyBuilds\RW.Base.22.210.0020.zip" /description "This package contains all screens" /level "1"



Write-Host "Backing up the Customization Zip..."

#! Get the current date in the format "dd-MM-yyyy"
$todayDate = Get-Date -Format "dd-MM-yyyy"

#! source and destination directories
$sourceDir = "C:\Daily2022R2Builds\*zip"
$destinationDir = "C:\Backups\pkg-backups\"

#! listing all the directories in destination
$existingDirs = Get-ChildItem -Path $destinationDir -Directory
$count = 0

#// counting how many dirs./Folders  created today
foreach ($directory in $existingDirs) {
    $creationDate = $directory.CreationTime.ToString("dd-MM-yyyy")
    
    if ($creationDate -eq $todayDate) {
        $count++
    }
}
#Set a variable to name todays folder in format (<Today's date>-<count>)
$newDir = "{0}-{1}" -f $todayDate, $count

# create new directory with todays date by using $newDir variable
New-Item -ItemType Directory -Force -Path "$destinationDir\$newDir"

# copy files from source to new directory created.
Copy-Item -Path "$sourceDir" -Destination "$destinationDir\$newDir" -Recurse

# Change location to latest created directory
Set-Location $destinationDir\$newDir

# Backing up all the files to s3bucket s3: customization-files
aws s3 cp $destinationDir\$newDir s3://ustomization-files/$newDir --recursive

Write-Host "Files Backed-up at : $destinationDir\$newDir"

exit 0
Exit with a success code
