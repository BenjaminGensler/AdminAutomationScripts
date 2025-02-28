# Powershell Script Tools for Admins by Admins

## Prerequisites

- Windows operating system
- PowerShell
- Administrative privileges

## Usage

1. Clone the repository or download the script file `Uninstall-Microsoft365Apps.ps1`.
2. Open PowerShell with administrative privileges.
3. Navigate to the directory where the script is located.
4. Run the script:

   - open powershell
   - change directory to install location (**cd 'File location'**)
   - in powershell type **.\Uninstall-Microsoft365Apps.ps1**

# Scripts

## Uninstall-Microsoft365Apps
A PowerShell script to uninstall Microsoft 365 Apps for enterprise and OneNote from Windows devices.
Known Bugs:
(Fixed as of 2/28/25 11:40) - If run through a package manager the following applications may fail to uninstall: "Microsoft 365 Apps 企業版 - zh-tw", "Microsoft 365 企业应用版 - zh-cn", and "엔터프라이즈용 Microsoft 365 앱 - ko-kr"
   (Current workaround: Run the file through powershell and let it run until script ends. )


## clear-AllUserProfiles
A Powershell script to remove all user accounts from a device. Useful for re-provisioning devices by cleaning out old user profiles.
Known Bugs:
- If run through a package manager you may receive the error "No User exists for *" and that it has failed to run a task. While it throws an error, in actuality the code has run successfully and if run again it will throw a successfully run prompt

