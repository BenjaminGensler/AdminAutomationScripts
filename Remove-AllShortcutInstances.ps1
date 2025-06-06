function Remove-AllShortcutInstances {
    <#
    .SYNOPSIS
    Removes all user shortcuts from the Desktop and Taskbar for all users on the system. The application itself is not uninstalled from the system.

    .DESCRIPTION
    This function deletes shortcuts from the Desktop and Taskbar for each user profile found in C:\Users.
    It ensures that only unique shortcuts are removed.

    .EXAMPLE
    Remove-AllShortcutInstances -Item "ApplicationName"
    #>
    
    [CmdletBinding()]
    param($item)

    # Get all user profile directories in C:\Users
    $userProfiles = Get-ChildItem -Path "C:\Users" -Directory

    foreach ($profile in $userProfiles) {
        try {
            # Attempt to delete the item from Users Desktop
            # Write-Output "Deleting $($item) from $($profile) Desktop"
            Remove-Item -Path "$($profile.FullName)\Desktop\$item.lnk" -Force -ErrorAction SilentlyContinue
        } catch {
            # Suppress any errors silently
            continue
        }

        try {
            # Attempt to delete the item from Users Taskbar
            # Write-Output "Deleting $($item) from $($profile) TaskBar"
            Remove-Item -Path "$($profile.FullName)\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\$item.lnk" -Force -ErrorAction SilentlyContinue
        }
        catch {
            # Suppress any errors silently
            continue
        }
    }
}
