# Created by: Benjamin Gensler
# Date: 5/16/2025
# Description: This is used for name changes usually through AD. This allows users to keep their files and everything else.
# Note: Please change the below variables $oldUserName and $newUserName to the previous and new names for the user. Below are 2 steps surrounded by '*'s

# *************** - STEPS - ******************************
# Step 1. 
# ****** Change $olduserName to desired user name *******
$oldUserName = "oldUserName"   # Current folder name

# Step 2. (Final Step)
# ****** Change $newUserName to desired new name *******
$newUserName = "newUserName"  # New folder name

# *************** - STEPS - ******************************

$oldPath = "C:\Users\$oldUserName"
$newPath = "C:\Users\$newUserName"

# Check if the old folder exists
if (-not (Test-Path -Path $oldPath)) {
    Write-Host "Error: The folder '$oldPath' does not exist. Check if your oldUserName variable is correctly labeled"
    exit # cancels in case the user folder doesn't exist on this given computer (Double check to make sure you have the correct name
}

# Ensure the new folder name does not already exist
if (Test-Path -Path $newPath) {
    Write-Host "Error: The folder '$newPath' already exists."
    exit # cancels in case either the script was already run or if a user already exists with the same name
}

# Rename the folder
try {
    Rename-Item -Path $oldPath -NewName $newUserName
    Write-Host "Successfully renamed '$oldPath' to '$newPath'."
} catch {
    Write-Host "Error: Failed to rename the folder. $_  Please make sure you have permissions to change this folder name."
    exit
}

# Update the registry to reflect the new folder name
# If the given users folder is not changed then issues may appear
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
$profileList = Get-ChildItem -Path $registryPath

foreach ($profile in $profileList) {
    $profilePath = Get-ItemProperty -Path $profile.PSPath | Select-Object -ExpandProperty ProfileImagePath
    Write-Host "Checking profile: $profilePath against old Path: $oldPath"
    if ($profilePath -eq $oldPath) {
        try {
            Set-ItemProperty -Path $profile.PSPath -Name ProfileImagePath -Value $newPath
            Write-Host "Updated registry entry for '$oldPath' to '$newPath'."
        } catch {
            Write-Host "Error: Failed to update the registry. $_"
            exit
        }
    }
}
