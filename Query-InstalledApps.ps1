# Benjamin Gensler
# 3/3/2025
# This script checks for the presence of specified applications on a computer and outputs the results to a text file.

# Define the list of applications to check
$applicationsToCheck = @(
    "Application 1",
    "Application 2",
    "Application 3"
)

$uninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
)

# Change name to desired path to save this at
$path = "\C:\Users\Username\Desktop\InstalledApps.txt"

# Get the name of the current computer
$computer = (Get-CimInstance -ClassName Win32_ComputerSystem).Name

Write-Host "Checking installed programs on this device..."

# Output the computer name to the output file
"$computer" | Out-File -FilePath $path -Append



$programs = @()
foreach ($key in $uninstallKeys) {
    # Get the list of installed programs from the registry
    $programs += Get-ItemProperty -Path "$key\*" | Select-Object DisplayName
}

# list to hold the results for the current computer
$appCheckResults = @()

# Check if each application is installed
foreach ($app in $applicationsToCheck) {
    # Check if the application is installed on the current computer
    $isInstalled = $programs | Where-Object { $_.DisplayName -like "*$app*" }

    # If the application is installed and not already in the results, add it
    if ($isInstalled -and ($appCheckResults -notcontains $app)) {
        $appCheckResults += $app
    }
}

# Get the list of installed programs on the remote computer
$WMIPrograms = Get-WmiObject -Class Win32_Product

# Check if each application is installed
    foreach ($app in $applicationsToCheck) {
        $isInstalled = $WMIPrograms | Where-Object { $_.Name -like "*$app*" }
        if ($isInstalled -and ($appCheckResults -notcontains $app)) {
            $appCheckResults += $app
        }
    }

# Append the results to the output file
if ($appCheckResults.Count -gt 0) {
    $appCheckResults | ForEach-Object {"  $_" | Out-File -FilePath $path -Append}
} else {
    Throw "No specified applications installed."
}


