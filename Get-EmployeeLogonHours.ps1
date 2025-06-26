# Author: Benjamin Gensler
# Description: This script retrieves user logon hours from Active Directory and exports them to a CSV file. This should work universally and requires little to no modification. It is designed to be run on a domain controller or a machine with the Active Directory module installed. The script decodes the logon hours into a readable format for each day of the week and saves the results in a CSV file.
# Active Directory formats the logonHours variable based on UTC or GMT time and in a binary based format, which can make the binary impossibly difficult to read. This version is a universal edition that is able to pull to correct times based on your timezone. As long as you have your timezone set properly in your Domain Controller this will make a correct version of your users time. 
# Note: This script doesn't handle split time such as someone who may have logon hours from 4AM - 12PM followed by a break in logon hours and then jumps back into 2PM - 7PM. The excel file will output that as 4AM-7PM.
# Version: 2.0 (Worldwide Edition)
# Requirements: Active Directory module for PowerShell
# Before Use: If you would like to use any of the following features or filters in the script, please uncomment the lines and change the values as needed. The script is designed to be flexible and can be modified to suit your needs.
# 1. File Location
# Change the $fileSaveLocation variable to the desired file location where you want to save the CSV file.

# 2. Group Name (if you want to filter out users based on group membership)
# Uncomment lines 26, 28, and 37  and change the $groupName variable to the desired group name. The script will then filter out users who are members of that group.

# 3. Department filters (if you want to exclude certain departments)
# Uncomment lines 33, 34, 35 and change the department names in the $filter variable to exclude specific departments. You can add or remove departments as needed by copying line 31 if additional departments need to be avoided.

# 4. Display Name filters (if you want to exclude certain users by their display name)
# Uncomment lines 26 and change the display names in the $filter variable to exclude specific users. You can add or remove display names as needed.

# 5. Logon hours filters (if you want to exclude users based on their logon hours)
# Uncomment lines 39 and change the logon hours condition in the $filter variable to exclude users based on their logon hours. You can modify the condition to suit your needs. Read more about this on line 36
# 6. Regular hours settings - Change the values $startingtime and $endingtime to the expected hours. This way users who have special logon access on monday for an additional hour but has a regular 9-5 hour access the rest of the week will only show the times for monday and 'regular hours' the rest of the time
$fileSaveLocation = "Desktop" # Please change this to the desired file location where you want to save the CSV file

# # Get the group name (Please change group name example if desired to use this)
# $groupName = "Example Group Name"
# # Get the members of the group
# $groupMembers = Get-ADGroupMember -Identity $groupName | Where-Object { $_.objectClass -eq "user" } | Select-Object -ExpandProperty SamAccountName

#Different version but only with the properties of DisplayName displayed:
$filter = {
    $_.objectClass -eq "user" -and 
    # $_.Department -ne "example department" -and 
    # $_.Department -ne "" -and 
    # $_.Department -ne $null -and
    # $_.DisplayName -ne "User's DisplayName" -and
    # $_.SamAccountName -notin $groupMembers -and
    #The below line is an option filter you can add if you want to avoid a standardized list of users with the provided login hours (The example one is a basic 9-5 in base time zone UTC+0)
    # (($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join "") -ne "000000000000000000000000000000001111111000000001000000001111111000000001000000001111111000000001000000001111111000000001000000001111111000000001000000000000000000000000" -and
    $_.logonHours -ne $null
}

#Time zone limits
$startingTime = 9
$endingTime = 17 # Essentially 5pm in military time

# Get the current time zone
$timeZone = Get-TimeZone

# Get the BaseUtcOffset value
$difference = $timeZone.BaseUtcOffset.hours

# Determine the starting position based on the time zone offset
if ($difference -ge 8) {
    $startingPosition = 160 # Positive values greater than a factor of 8
} elseif ($difference -le -8) {
    $startingPosition = 8   # Negative values greater than a factor of 8
} else {
    $startingPosition = 0   # Default starting position
}

$collectionValue1 = 8 + ($difference % 8) # Calculate the collection value based on the time zone offset
$collectionValue2 = 8 - $collectionValue1 # Calculate the second collection value (allowed to collect nothing)

# Define the days of the week and their corresponding base positions
$daysOfWeek = @{
    Sunday    = 0
    Monday    = 24
    Tuesday   = 48
    Wednesday = 72
    Thursday  = 96
    Friday    = 120
    Saturday  = 144
}

# Get the users and decode logonHours into separate columns for each day
$users = Get-ADUser -Filter * -Property DisplayName, Department, UserPrincipalName, logonHours | 
        Where-Object $filter | 
        Select-Object DisplayName, @{Name="Sunday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""

                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1)
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits = -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring(($startingPosition + 8 + $collectionValue1) % 168, $collectionValue2)
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8

                
                $firstSegment = $decodedHours.Substring($startingPosition % 168, $collectionValue1) # First 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring(($startingPosition + 8 + $collectionValue1) % 168, $collectionValue2) # Second 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8


                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1) # Third 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2) # Third 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8


                # Find the first and last positions of '1'
                $firstOne = $resultingDigits.IndexOf('1') # Position of the first '1'
                $lastOne = $resultingDigits.LastIndexOf('1') # Position of the last '1'


                # Format the allowed time range
                if ($firstOne -ge 0 -and $lastOne -ge 0 -and (-not ($firstOne -eq $startingTime -and $lastOne -eq $endingTime))) {
                    $lastOne = $lastOne + 1 # Adjust lastOne to include the last '1'
                    $allowedTime = "$firstOne AM - $lastOne PM"
                } elseif ($firstOne -eq $startingTime -and $lastOne -eq $endingTime) {
                    $allowedTime = "Regular Hours"
                } else {
                    $allowedTime = " - " # No valid time range found
                }
                $allowedTime
            }
        }}, @{Name="Monday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                # Write-Output "Starting position before set: $startingPosition"
                $startingPosition =($startingPosition + $daysOfWeek["Monday"]) % 168 # Calculate the starting position for Monday

                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1)
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits = -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2)
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8

                
                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1) # First 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2) # Second 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8


                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1) # Third 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2) # Third 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8


                # Find the first and last positions of '1'
                $firstOne = $resultingDigits.IndexOf('1') # Position of the first '1'
                $lastOne = $resultingDigits.LastIndexOf('1') # Position of the last '1'


                # Format the allowed time range
                if ($firstOne -ge 0 -and $lastOne -ge 0 -and (-not ($firstOne -eq $startingTime -and $lastOne -eq $endingTime))) {
                    $lastOne = $lastOne + 1 # Adjust lastOne to include the last '1'
                    $allowedTime = "$firstOne AM - $lastOne PM"
                } elseif ($firstOne -eq $startingTime -and $lastOne -eq $endingTime) {
                    $allowedTime = "Regular Hours"
                } else {
                    $allowedTime = " - " # No valid time range found
                }
                $allowedTime
            }
        }}, @{Name="Tuesday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                
                # Calculate the starting position for the given day
                $startingPosition =($startingPosition + $daysOfWeek["Tuesday"]) % 168

                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1)
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits = -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2)
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8

                
                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1) # First 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2) # Second 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8


                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1) # Third 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2) # Third 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8


                # Find the first and last positions of '1'
                $firstOne = $resultingDigits.IndexOf('1') # Position of the first '1'
                $lastOne = $resultingDigits.LastIndexOf('1') # Position of the last '1'


                # Format the allowed time range
                if ($firstOne -ge 0 -and $lastOne -ge 0 -and (-not ($firstOne -eq $startingTime -and $lastOne -eq $endingTime))) {
                    $lastOne = $lastOne + 1 # Adjust lastOne to include the last '1'
                    $allowedTime = "$firstOne AM - $lastOne PM"
                } elseif ($firstOne -eq $startingTime -and $lastOne -eq $endingTime) {
                    $allowedTime = "Regular Hours"
                } else {
                    $allowedTime = " - " # No valid time range found
                }
                $allowedTime
            }
        }}, @{Name="Wednesday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                
                # Calculate the starting position for the given day
                $startingPosition =($startingPosition + $daysOfWeek["Wednesday"]) % 168

                
                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1)
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits = -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2)
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8

                
                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1) # First 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2) # Second 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8


                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1) # Third 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2) # Third 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8


                # Find the first and last positions of '1'
                $firstOne = $resultingDigits.IndexOf('1') # Position of the first '1'
                $lastOne = $resultingDigits.LastIndexOf('1') # Position of the last '1'

                # Format the allowed time range
                if ($firstOne -ge 0 -and $lastOne -ge 0 -and (-not ($firstOne -eq $startingTime -and $lastOne -eq $endingTime))) {
                    $lastOne = $lastOne + 1 # Adjust lastOne to include the last '1'
                    $allowedTime = "$firstOne AM - $lastOne PM"
                } elseif ($firstOne -eq $startingTime -and $lastOne -eq $endingTime) {
                    $allowedTime = "Regular Hours"
                } else {
                    $allowedTime = " - " # No valid time range found
                }
                $allowedTime
            }
        }}, @{Name="Thursday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                
                # Calculate the starting position for the given day
                $startingPosition =($startingPosition + $daysOfWeek["Thursday"]) % 168

                
                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1)
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits = -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2)
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8

                
                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1) # First 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2) # Second 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8


                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1) # Third 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2) # Third 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8


                # Find the first and last positions of '1'
                $firstOne = $resultingDigits.IndexOf('1') # Position of the first '1'
                $lastOne = $resultingDigits.LastIndexOf('1') # Position of the last '1'


                # Format the allowed time range
                if ($firstOne -ge 0 -and $lastOne -ge 0 -and (-not ($firstOne -eq $startingTime -and $lastOne -eq $endingTime))) {
                    $lastOne = $lastOne + 1 # Adjust lastOne to include the last '1'
                    $allowedTime = "$firstOne AM - $lastOne PM"
                } elseif ($firstOne -eq $startingTime -and $lastOne -eq $endingTime) {
                    $allowedTime = "Regular Hours"
                } else {
                    $allowedTime = " - " # No valid time range found
                }
                $allowedTime
            }
        }}, @{Name="Friday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                
                # Calculate the starting position for the given day
                $startingPosition =($startingPosition + $daysOfWeek["Friday"]) % 168

                
                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1)
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits = -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2)
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8

                
                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1) # First 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2) # Second 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8


                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1) # Third 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2) # Third 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8


                # Find the first and last positions of '1'
                $firstOne = $resultingDigits.IndexOf('1') # Position of the first '1'
                $lastOne = $resultingDigits.LastIndexOf('1') # Position of the last '1'


                # Format the allowed time range
                if ($firstOne -ge 0 -and $lastOne -ge 0 -and (-not ($firstOne -eq $startingTime -and $lastOne -eq $endingTime))) {
                    $lastOne = $lastOne + 1 # Adjust lastOne to include the last '1'
                    $allowedTime = "$firstOne AM - $lastOne PM"
                } elseif ($firstOne -eq $startingTime -and $lastOne -eq $endingTime) {
                    $allowedTime = "Regular Hours"
                } else {
                    $allowedTime = " - " # No valid time range found
                }
                $allowedTime
            }
        }}, @{Name="Saturday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""

                $startingPosition =($startingPosition + $daysOfWeek["Saturday"]) % 168
                
                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1)
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits = -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring($startingPosition + 8 + $collectionValue1, $collectionValue2)
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8

                
                $firstSegment = $decodedHours.Substring($startingPosition, $collectionValue1) # First 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring(($startingPosition + 8 + $collectionValue1) % 168, $collectionValue2) # Second 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8


                $firstSegment = $decodedHours.Substring(($startingPosition) % 168, $collectionValue1) # Third 8 digits for Sunday
                $charArray = $firstSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $secondSegment = $decodedHours.Substring(($startingPosition + 8 + $collectionValue1) % 168, $collectionValue2) # Third 8 digits for Sunday
                $charArray = $secondSegment.ToCharArray() # Convert string to character array
                [Array]::Reverse($charArray)            # Reverse the array
                $resultingDigits += -join $charArray # Join the reversed array back into a string

                $startingPosition += 8 # Move the starting position forward by 8


                # Find the first and last positions of '1'
                $firstOne = $resultingDigits.IndexOf('1') # Position of the first '1'
                $lastOne = $resultingDigits.LastIndexOf('1') # Position of the last '1'


                # Format the allowed time range
                if ($firstOne -ge 0 -and $lastOne -ge 0 -and (-not ($firstOne -eq $startingTime -and $lastOne -eq $endingTime))) {
                    $lastOne = $lastOne + 1 # Adjust lastOne to include the last '1'
                    $allowedTime = "$firstOne AM - $lastOne PM"
                } elseif ($firstOne -eq $startingTime -and $lastOne -eq $endingTime) {
                    $allowedTime = "Regular Hours"
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
$users | Export-Csv -Path "$fileSaveLocation\logonHours-$todaysDate.csv" -NoTypeInformation
