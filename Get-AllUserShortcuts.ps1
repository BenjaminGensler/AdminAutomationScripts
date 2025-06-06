function Get-AllUserShortcuts {
    <#
    .SYNOPSIS
    Retrieves all user shortcuts from the Desktop and Taskbar for all users on the system.

    .DESCRIPTION
    This function collects shortcuts from the Desktop and Taskbar for each user profile found in C:\Users.
    It ensures that only unique shortcuts are returned.

    .EXAMPLE
    Get-AllUserShortcuts
    #>
    
    [CmdletBinding()]
    param()

    # Get all user profile directories in C:\Users
    $userProfiles = Get-ChildItem -Path "C:\Users" -Directory

    foreach ($profile in $userProfiles) {
        $shortcuts = Get-ChildItem -Path "$($profile.FullName)\Desktop"
        $shortcuts += Get-ChildItem -Path "$($profile.FullName)\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"

        # Ensure shortcuts contain only unique items
        $shortcuts = $shortcuts | Select-Object -Unique
    }

    # Output the list of shortcuts
    $shortcuts | ForEach-Object {
        Write-Output $_.FullName
    }
}
