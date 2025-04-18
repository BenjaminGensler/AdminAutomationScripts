# Created by: Benjamin Gensler
# Date: 4/18/2025
# Description: This is used to remove applications from all users taskbars and desktops

# shortcuts to remove
$items = @(
    "Application Name 1",
    "Application Name 2",
    "Application Name 3"
)
# Get all user profile directories in C:\Users
$userProfiles = Get-ChildItem -Path "C:\Users" -Directory
foreach ($profile in $userProfiles) {
    foreach ($item in $items){
        try {
            # Attempt to delete the item from Users Desktop
            # Write-Host "Deleting $($item) from $($profile) Desktop"
            Remove-Item -Path "$($profile.FullName)\Desktop\$item.lnk" -Force -ErrorAction SilentlyContinue
        } catch {
            # Suppress any errors silently
            continue
        }

        try {
            # Attempt to delete the item from Users Taskbar
            # Write-Host "Deleting $($item) from $($profile) TaskBar"
            Remove-Item -Path "$($profile.FullName)\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\$item.lnk" -Force -ErrorAction SilentlyContinue
        }
        catch {
            # Suppress any errors silently
            continue
        }
    }
}
