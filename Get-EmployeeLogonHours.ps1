# -------------------------------------------------------------------
# Script Name: Get-EmployeeLogonHours.ps1
# Description: This script retrieves Active Directory users, filters them based on specific criteria, 
#              and decodes their logon hours into readable time ranges for each day of the week. 
#              This results in a report that lists users along with their allowed logon hours for each 
#              day from Sunday to Saturday.
# Author: Benjamin Gensler
# Created Date: 6/11/2025
# Last Modified: 6/12/2025
# -------------------------------------------------------------------
# Usage:
# - Ensure you have the Active Directory module installed and imported.
# - Update the `$groupName` variable to specify the group whose members should be excluded.
# - Run the script to generate a report of employee logon hours.
# - The output will include the display name and logon hours for Sunday through Saturday.
# -------------------------------------------------------------------
# Requirements:
# - Active Directory module (`Import-Module ActiveDirectory`)
# - Permissions to query Active Directory
# -------------------------------------------------------------------
# Output:
# - A list of users with their logon hours decoded into readable time ranges.
# -------------------------------------------------------------------

#-------------------------------------------------------------------
# Before Use:
# - Before running this file please make the desired changes to the file by following the instructions from the below lines:
# - Lines 31, 32, & 399


# Uncomment out the following 3 lines as well as the line in $filter if you would like to exclude any users from a given group
# Also change the $groupName variable to the name of the group you want to exclude the members of users from this report
# $groupName = "GroupName"
# # Get the members of the group
# $groupMembers = Get-ADGroupMember -Identity $groupName | Where-Object { $_.objectClass -eq "user" } | Select-Object -ExpandProperty SamAccountName

#Different version but only with the properties of DisplayName displayed:
$filter = {
    $_.objectClass -eq "user" -and 
    $_.Department -ne "" -and 
    $_.Department -ne $null -and
    # $_.SamAccountName -notin $groupMembers -and
    $_.logonHours -ne $null
}

# Get the users and decode logonHours into separate columns for each day
$users = Get-ADUser -Filter * -Property DisplayName, Department, UserPrincipalName, logonHours | 
        Where-Object $filter | 
        Select-Object DisplayName, @{Name="Sunday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                
                $firstSegment = $decodedHours.Substring(0, 2)
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits = -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(10, 6)
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                
                $firstSegment = $decodedHours.Substring(8, 2) # First 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(18, 6) # Second 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $firstSegment = $decodedHours.Substring(16, 2) # Third 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(26, 6) # Third 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                # Write-Output "Resulting Digits: $resultingDigits"

                # Find the first and last positions of '1'
                $firstOne = $resultingDigits.IndexOf('1') # Position of the first '1'
                $lastOne = $resultingDigits.LastIndexOf('1') # Position of the last '1'

                # Write-Output "First '1' Position: $firstOne"
                # Write-Output "Last '1' Position: $lastOne"

                # Format the allowed time range
                if ($firstOne -ge 0 -and $lastOne -ge 0) {
                    $lastOne = $lastOne + 1 # Adjust lastOne to include the last '1'
                    $allowedTime = "$firstOne AM - $lastOne PM" # Format as AM/PM
                } else {
                    $allowedTime = " - " # No valid time range found
                }
                $allowedTime
            }
        }}, @{Name="Monday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                
                $firstSegment = $decodedHours.Substring(24, 2)
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits = -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(34, 6)
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                
                $firstSegment = $decodedHours.Substring(32, 2) # First 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(42, 6) # Second 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $firstSegment = $decodedHours.Substring(40, 2) # Third 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(50, 6) # Third 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                # Write-Output "Resulting Digits: $resultingDigits"

                # Find the first and last positions of '1'
                $firstOne = $resultingDigits.IndexOf('1') # Position of the first '1'
                $lastOne = $resultingDigits.LastIndexOf('1') # Position of the last '1'

                # Write-Output "First '1' Position: $firstOne"
                # Write-Output "Last '1' Position: $lastOne"

                # Format the allowed time range
                if ($firstOne -ge 0 -and $lastOne -ge 0) {
                    $lastOne = $lastOne + 1 # Adjust lastOne to include the last '1'
                    $allowedTime = "$firstOne AM - $lastOne PM"
                } else {
                    $allowedTime = " - " # No valid time range found
                }
                $allowedTime
            }
        }}, @{Name="Tuesday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                
                $firstSegment = $decodedHours.Substring(48, 2)
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits = -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(58, 6)
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                
                $firstSegment = $decodedHours.Substring(56, 2) # First 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(66, 6) # Second 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $firstSegment = $decodedHours.Substring(64, 2) # Third 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(74, 6) # Third 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                # Write-Output "Resulting Digits: $resultingDigits"

                # Find the first and last positions of '1'
                $firstOne = $resultingDigits.IndexOf('1') # Position of the first '1'
                $lastOne = $resultingDigits.LastIndexOf('1') # Position of the last '1'

                # Write-Output "First '1' Position: $firstOne"
                # Write-Output "Last '1' Position: $lastOne"

                # Format the allowed time range
                if ($firstOne -ge 0 -and $lastOne -ge 0) {
                    $lastOne = $lastOne + 1 # Adjust lastOne to include the last '1'
                    $allowedTime = "$firstOne AM - $lastOne PM"
                } else {
                    $allowedTime = " - " # No valid time range found
                }
                $allowedTime
            }
        }}, @{Name="Wednesday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                
                $firstSegment = $decodedHours.Substring(72, 2)
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits = -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(82, 6)
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                
                $firstSegment = $decodedHours.Substring(80, 2) # First 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(90, 6) # Second 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $firstSegment = $decodedHours.Substring(88, 2) # Third 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(98, 6) # Third 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                # Write-Output "Resulting Digits: $resultingDigits"

                # Find the first and last positions of '1'
                $firstOne = $resultingDigits.IndexOf('1') # Position of the first '1'
                $lastOne = $resultingDigits.LastIndexOf('1') # Position of the last '1'

                # Write-Output "First '1' Position: $firstOne"
                # Write-Output "Last '1' Position: $lastOne"

                # Format the allowed time range
                if ($firstOne -ge 0 -and $lastOne -ge 0) {
                    $lastOne = $lastOne + 1 # Adjust lastOne to include the last '1'
                    $allowedTime = "$firstOne AM - $lastOne PM"
                } else {
                    $allowedTime = " - " # No valid time range found
                }
                $allowedTime
            }
        }}, @{Name="Thursday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                
                $firstSegment = $decodedHours.Substring(96, 2)
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits = -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(106, 6)
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                
                $firstSegment = $decodedHours.Substring(104, 2) # First 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(114, 6) # Second 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $firstSegment = $decodedHours.Substring(112, 2) # Third 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(122, 6) # Third 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                # Write-Output "Resulting Digits: $resultingDigits"

                # Find the first and last positions of '1'
                $firstOne = $resultingDigits.IndexOf('1') # Position of the first '1'
                $lastOne = $resultingDigits.LastIndexOf('1') # Position of the last '1'

                # Write-Output "First '1' Position: $firstOne"
                # Write-Output "Last '1' Position: $lastOne"

                # Format the allowed time range
                if ($firstOne -ge 0 -and $lastOne -ge 0) {
                    $lastOne = $lastOne + 1 # Adjust lastOne to include the last '1'
                    $allowedTime = "$firstOne AM - $lastOne PM"
                } else {
                    $allowedTime = " - " # No valid time range found
                }
                $allowedTime
            }
        }}, @{Name="Friday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                
                $firstSegment = $decodedHours.Substring(120, 2)
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits = -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(130, 6)
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                
                $firstSegment = $decodedHours.Substring(128, 2) # First 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(138, 6) # Second 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $firstSegment = $decodedHours.Substring(136, 2) # Third 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(146, 6) # Third 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                # Write-Output "Resulting Digits: $resultingDigits"

                # Find the first and last positions of '1'
                $firstOne = $resultingDigits.IndexOf('1') # Position of the first '1'
                $lastOne = $resultingDigits.LastIndexOf('1') # Position of the last '1'

                # Write-Output "First '1' Position: $firstOne"
                # Write-Output "Last '1' Position: $lastOne"

                # Format the allowed time range
                if ($firstOne -ge 0 -and $lastOne -ge 0) {
                    $lastOne = $lastOne + 1 # Adjust lastOne to include the last '1'
                    $allowedTime = "$firstOne AM - $lastOne PM"
                } else {
                    $allowedTime = " - " # No valid time range found
                }
                $allowedTime
            }
        }}, @{Name="Saturday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                
                $firstSegment = $decodedHours.Substring(144, 2)
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits = -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(154, 6)
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                
                $firstSegment = $decodedHours.Substring(152, 2) # First 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(162, 6) # Second 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $firstSegment = $decodedHours.Substring(160, 2) # Third 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string
                $secondSegment = $decodedHours.Substring(2, 6) # Third 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                # Write-Output "Resulting Digits: $resultingDigits"

                # Find the first and last positions of '1'
                $firstOne = $resultingDigits.IndexOf('1') # Position of the first '1'
                $lastOne = $resultingDigits.LastIndexOf('1') # Position of the last '1'

                # Write-Output "First '1' Position: $firstOne"
                # Write-Output "Last '1' Position: $lastOne"

                # Format the allowed time range
                if ($firstOne -ge 0 -and $lastOne -ge 0) {
                    $lastOne = $lastOne + 1 # Adjust lastOne to include the last '1'
                    $allowedTime = "$firstOne AM - $lastOne PM"
                } else {
                    $allowedTime = " - " # No valid time range found
                }
                $allowedTime
            }
        }} | 
        Sort-Object DisplayName

# Get today's date for the filename
$todaysDate = Get-Date -Format "yyyy-MM-dd"

# Putting the $users in a list in an excel document
# Note: please change the Desired FileLocation and file name below 
$users | Export-Csv -Path "\\DesiredFileLocation\NameOfFile-$todaysDate.csv" -NoTypeInformation
