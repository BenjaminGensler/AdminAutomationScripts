# Benjamin Gensler
# 4/2/25
# Create a shortcut of a file/folder in a specified location
# !!! Note: Please change the paths of both the $targetPath and $shortcutPath to the desired target file and shortcut location respectively

# ---------- Change the below files -----------------

$targetPath = "C:\Users\Public\Documents\example.txt"   # Change this to the path of the file/folder you want to create a shortcut of
$shortcutPath = "C:\Users\Public\Desktop\example.lnk"   # Change this to the path you would like the shortcut to go and the name of the shortcut at the end. (Currently pointing to the all users desktops (Current name of shortcut will be 'example'))

# ---------------------------------------------------

function create-Shortcut($targetPath, $shortcutPath) {
    #Creates a COM object
    $WScriptShell = New-Object -ComObject WScript.Shell
    # determines the shortcut location for the COM Object
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    # sets targetPath for COM Object
    $shortcut.TargetPath = $targetPath
    # Creates the shortcut
    $shortcut.Save()
}

create-Shortcut($targetPath, $shortcutPath)
