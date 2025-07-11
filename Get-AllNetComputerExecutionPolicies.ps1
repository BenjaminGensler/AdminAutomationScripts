# Benjamin Gensler
# 7/11/2025
# This script checks the execution policies of all computers and exports the results to a CSV file.

# Requirements:
# - Active Directory module (or run through a domain controller)
# - PowerShell remoting enabled on target computers

# Before Using:
# If necessary please change the $fileSaveLocation on line 12 to your desired file location you would like this .csv file to be created at
# Define the file save location
$fileSaveLocation = "$env:USERPROFILE\Desktop"

# Filter for computers
$filter = {
    $_.Name -like "*" -and 
    $_.Name -notlike ""
}

$computers = Get-ADComputer -Filter * -Property Name | 
    Where-Object $filter | 
    Select-Object Name | 
    Sort-Object Name

$executionPolicies = @()

# Loop through each computer to get execution policies
foreach ($computer in $computers) {
    try {
        Write-Host "Checking $($computer.Name)..." -ForegroundColor Yellow

        $policy = Invoke-Command -ComputerName $computer.Name -ScriptBlock {
            Get-ExecutionPolicy
        } -ErrorAction Stop

        $executionPolicies += [PSCustomObject]@{
            ComputerName = $computer.Name
            Policies     = $policy.value
        }
    } catch {
        $executionPolicies += [PSCustomObject]@{
            ComputerName = $computer.Name
            Policies     = "Error"
        }

        continue
    }
}

# Get the current date in the format yyyy-MM-dd
$todaysDate = Get-Date -Format "yyyy-MM-dd"

# Putting the $executionPolicies in a list in an excel document
$executionPolicies | Select-Object ComputerName, Policies | Export-Csv -Path "$fileSaveLocation\allComputers-ExecutionPolicies-$todaysDate.csv" -NoTypeInformation
