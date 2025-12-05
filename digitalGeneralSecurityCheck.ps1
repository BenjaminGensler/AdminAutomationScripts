## Digital General Security Checklist Script
# Check Bitlocker---------------------------------------------------------------------------------------------------------------------
$bitlockerVolumes = Get-BitLockerVolume | Where-Object { $_.ProtectionStatus -ne 'On' }
if($bitlockerVolumes){
    Write-Host "ERROR - No Bitlocker Enabled"
}
else{
    Write-Host "Successful - Bitlocker Enabled"
}

# Check Execution Policy (Only works if run manually, else always ERROR)--------------------------------------------------------------------------------------------------------------
# $restrictionPolicy = Get-ExecutionPolicy

# if($restrictionPolicy -ne 'Restricted'){
#     Write-Host "ERROR - Bad Execution Policy"
# }
# else{
#     Write-Host "Successful - ExecutionPolicy"
# }

# Check Browser Extensions-----------------------------------------------------------------------------------------------------------
$safeExtensions = @(
    #Edge Extensions

    #Chrome Extensions
)

$currentusers = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | Select-Object ProfileImagePath

$users = $currentUsers | Select-Object @{Name='UserFolder';Expression={Split-Path $_.ProfileImagePath -Leaf}}

Foreach($user in $users){
    $extensionPaths = @(
        "C:\Users\$($user.UserFolder)\AppData\Local\Google\Chrome\User Data\Default\Extensions",  #Chrome Path
        "C:\Users\$($user.UserFolder)\AppData\Local\Microsoft\Edge\User Data\Default\Extensions"  #Edge path
    )

    foreach($path in $extensionPaths){
        if(Test-Path -Path $path){
            $folders = Get-ChildItem -Path $path -Directory | Select-Object -ExpandProperty Name
            $potentiallyUnsafe = $folders | Where-Object { $_ -notin $safeExtensions }
            if($potentiallyUnsafe){
                Write-Host " `nERROR - Unsafe extensions found @ $($path) for $($user.UserFolder) `n$($potentiallyUnsafe -join ',')`n"
            }
            else{
                # Write-Host "Successful - Only safe extensions for $($user.UserFolder)"
            }
        }
        else{
            # Write-Host "No extensions found for $($user.UserFolder)"
        }
    }
}

# Check for potentially dangerous files (passwords, etc.)--------------------------------------------------------------------------------
$currentusers = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | Select-Object ProfileImagePath

$users = $currentUsers | Select-Object @{Name='UserFolder';Expression={Split-Path $_.ProfileImagePath -Leaf}}

Foreach($user in $users){
    # Define search paths
    $searchPaths = @(
        "C:\Users\$($user.UserFolder)\Downloads",
        "C:\Users\$($user.UserFolder)\Desktop",
        "C:\Users\$($user.UserFolder)\Documents"
    )
    # Define sensitive keywords
    $sensitiveKeywords = @(
        "*password*", "*pass*", "*pwd*", "*login*", "*credential*", 
        "*secret*", "*key*", "*token*", "*backup*", "*recovery*",
        "*admin*", "*user*", "*account*", "*config*", "*setting*",
        "*database*", "*db*", "*sql*", "*backup*", "*dump*",
        "*confidential*", "*private*", "*secure*", "*auth*"
    )

    # Search for files matching sensitive keywords
    foreach($path in $searchPaths){
        if(Test-Path -Path $path){
            foreach($keyword in $sensitiveKeywords){
                $files = Get-ChildItem -Path $path -Recurse -Filter $keyword -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '\.(txt|docx|xlsx|pdf|csv|log|xml|json|sql|bak|conf|ini|cfg)$' }
                # If files are found, output a warning of potentially sensitive files
                if($files){
                    Write-Host "`nWARNING - Potentially sensitive files found for $($user.UserFolder) in $($path):"
                    # List the found files
                    foreach($file in $files){
                        Write-Host " - $($file.FullName)"
                    }
                }
            }
        }
    }
}
