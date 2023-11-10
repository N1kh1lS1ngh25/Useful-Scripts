Write-Host "Starting script..."

Write-Host "Creating RW.Base.22.210.0020"
& "C:\Program Files\Acumatica ERP\rwdev22r2\Bin\PX.CommandLine.exe" /method BuildProject /in "C:\Acumatica Packages\2022R2\RWPackages\RW.Base.22.210.0020" /out "C:\Daily2022R2Builds\RW.Base.22.210.0020.zip" /description "This package contains all screens but the GST related screens & dll." /level "1"



Write-Host "Backing up the files..."

#! Get the current date in the format "dd-MM-yyyy"
$todayDate = Get-Date -Format "dd-MM-yyyy"
#! source and destination directories
$sourceDir = "C:\Daily2022R2Builds\*zip"
$destinationDir = "C:\Backups\pkg-backups\"
#! listing all the directories in destination
$existingDirs = Get-ChildItem -Path $destinationDir -Directory
$count = 0
#// counting how many dirs. created today
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

# Backing up all the files to s3: readywire-files
aws s3 cp $destinationDir\$newDir s3://readywire-packages/$newDir --recursive
Write-Host "Files Backed-up at : $destinationDir\$newDir"

exit 0
Exit with a success code
