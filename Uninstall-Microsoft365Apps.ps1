# Created by: Benjamin Gensler
# Script to help uninstall Microsoft 365 Apps for enterprise and OneNote from Windows devices
# These applications are usually installed immediately after a fresh Windows installation
# This script requires administrative privileges to uninstall programs (No interaction required after running the script)

# List of application names to uninstall
$appNames = @(
    "Microsoft 365 - en-us",
    "Aplicaciones de Microsoft 365 para empresas - es-es",
    "Aplicaciones de Microsoft 365 para empresas - es-mx",
    "Microsoft 365 Apps for enterprise - en-gb",
    "Microsoft 365 Apps for enterprise - en-us",
    "Microsoft 365 Apps for enterprise - fr-ca",
    "Microsoft 365 Apps for enterprise - fr-fr",
    "Microsoft 365 Apps for enterprise - ja-jp",
    "Microsoft 365 Apps for enterprise - th-th",
    "Microsoft 365 Apps para Grandes Empresas - pt-br",
    "Microsoft 365 Apps*- zh-tw",
    "Microsoft 365*- zh-cn",
    "*Microsoft 365*- ko-kr",
    "Microsoft OneNote - en-gb",
    "Microsoft OneNote - en-us",
    "Microsoft OneNote - es-es",
    "Microsoft OneNote - es-mx",
    "Microsoft OneNote - fr-ca",
    "Microsoft OneNote - fr-fr",
    "Microsoft OneNote - ja-jp",
    "Microsoft OneNote - ko-kr",
    "Microsoft OneNote - pt-br",
    "Microsoft OneNote - th-th",
    "Microsoft OneNote - zh-cn",
    "Microsoft OneNote - zh-tw"
)

# Registry key paths for installed programs to uninstall
$uninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
)

# Get a list of installed programs from the registry
$programs = foreach ($key in $uninstallKeys) {
    # Check if Path exists
    if (-not (Test-Path $key)) {
        continue
    }
    Get-ItemProperty -Path "$key\*" | ForEach-Object {
        # Creates a custom object with only necessary properties (Name and UninstallString)
        [PSCustomObject]@{
            Name = $_.DisplayName
            UninstallString = $_.UninstallString
        }
    }
}

# Output the list of programs (Uncomment if you want to see list of installed programs)
# $programs | Format-Table -AutoSize



# Function to uninstall a program by name
function Uninstall-Program {
    param (
        [string]$programName
    )

    # Find the program in the list of installed programs (Gets both name and uninstall string)
    $program = $programs | Where-Object { $_.Name -like "$programName" }
    # If the program is found, uninstall it if uninstall string is available
    if ($program) {
        if ($program.UninstallString) {
            Write-Host "Uninstalling $programName..."

            # Create the uninstall string for ClickToRun applications
            $uninstallString = $program.UninstallString
            if ($uninstallString -match "ClickToRun") {
                $uninstallString += " DisplayLevel=False"
            }

            # Starts the uninstall process through command prompt, waits for the current uninstall to finish before going to the next one
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $uninstallString -Wait -NoNewWindow
            Write-Host "$programName has been uninstalled."
        } else {
            Write-Host "No uninstall string found for $programName."
        }
    # If the program is not found, display a message
    } else {
        Write-Host "Program $programName not found."
    }
}


# Loop through the list of application names and uninstall each one
foreach ($app in $appNames){
    Uninstall-Program -programName $app
}
