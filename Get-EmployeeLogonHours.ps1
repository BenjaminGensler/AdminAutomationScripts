#Different version but only with the properties of DisplayName displayed:
$filter = {
    $_.objectClass -eq "user" -and 
    $_.Department -ne "" -and 
    $_.Department -ne $null -and
    $_.logonHours -ne $null
}


# Get the users and decode logonHours into separate columns for each day
$users = Get-ADUser -Filter * -Property DisplayName, Department, UserPrincipalName, logonHours | 
        Where-Object $filter | 
        Select-Object DisplayName, @{Name="Sunday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                $decodedHours.Substring(0, 24) # Extract Sunday (first 24 binary digits)
            }
        }}, @{Name="Monday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                $decodedHours.Substring(24, 24) # Extract Monday (next 24 binary digits)
            }
        }}, @{Name="Tuesday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                $decodedHours.Substring(48, 24) # Extract Tuesday (next 24 binary digits)
            }
        }}, @{Name="Wednesday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                $decodedHours.Substring(72, 24) # Extract Wednesday (next 24 binary digits)
            }
        }}, @{Name="Thursday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                $decodedHours.Substring(96, 24) # Extract Thursday (next 24 binary digits)
            }
        }}, @{Name="Friday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                $decodedHours.Substring(120, 24) # Extract Friday (next 24 binary digits)
            }
        }}, @{Name="Saturday"; Expression={
            if ($_.logonHours) {
                $decodedHours = ($_.logonHours | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') }) -join ""
                $decodedHours.Substring(144, 24) # Extract Saturday (next 24 binary digits)
            }
        }} | 
        Sort-Object DisplayName

# Get today's date for the filename
$todaysDate = Get-Date -Format "yyyy-MM-dd"

# Putting the $users in a list in an excel document
$users | Export-Csv -Path "\\DesiredFilePathLocation\logonHours-$todaysDate.csv" -NoTypeInformation
