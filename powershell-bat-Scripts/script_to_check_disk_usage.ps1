$Array = @()

# Retrieve disk information
$DiskInfo = Get-WmiObject Win32_LogicalDisk |
Select-Object DeviceID, 
@{Name = "TotalSize(GB)"; Expression = { "{0:N2}" -f ($_.Size / 1GB) } }, 
@{Name = "FreeSpace(GB)"; Expression = { "{0:N2}" -f ($_.FreeSpace / 1GB) } }, 
@{Name = "UsedSpace(GB)"; Expression = { "{0:N2}" -f (($_.Size - $_.FreeSpace) / 1GB) } }, 
@{Name = "FreeSpace(%)"; Expression = { "{0:N2}" -f (($_.FreeSpace / $_.Size) * 100) } }, 
@{Name = "UsedSpace(%)"; Expression = { "{0:N2}" -f ((($_.Size - $_.FreeSpace) / $_.Size) * 100) } }

# Loop through each disk and create a custom object for each
foreach ($disk in $DiskInfo) {
    $Row = New-Object PSObject -Property @{
        Disk_Name    = $disk.DeviceID
        "Total(GiB)" = $disk."TotalSize(GB)"
        "Free(GiB)"  = $disk."FreeSpace(GB)"
        "Used(GiB)"  = $disk."UsedSpace(GB)"
        "Free_%"     = $disk."FreeSpace(%)"
        "Used_%"     = $disk."UsedSpace(%)"
    }
    $Array += $Row
}

# Check if disk usage > 95%
$DisksAbove95 = $Array | Where-Object { [double]$_."Used_%" -gt 90 }


if ($DisksAbove95.Count -gt 0) {
    $DisksAbove95 | Select-Object Disk_Name, "Total(GiB)", "Free(GiB)", "Used(GiB)", "Free_%", "Used_%" | Format-Table -AutoSize
}
