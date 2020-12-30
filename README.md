# steam-iscsi-autostart
A script which is used as an autostart for Steam to wait for a iSCSI target to be connected and mounted.


## Usage
Copy this script to a folder in your users directory, e.g. `C:\Users\username\Powershell`. Next you'll need a shortcut or symlink in the autostart folder. To open the autostart folder, press WIN + R and type `shell:startup` and hit enter. Next, right-click and choose "New" and "Shortcut". Search for your script and hit "OK". After that, select the shortcut that you've just created, right-click it and select "Properties". Replace the string in "Target:" with `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -File C:\Users\<Username>\PowerShell\script.ps1 -NodeAddress <Node-Address> -DriveLetter <Drive-Letter>`. If you have a custom installation of Steam than you can use the third parameter for that, e.g. `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -File C:\Users\<Username>\PowerShell\script.ps1 -NodeAddress <Node-Address> -DriveLetter <Drive-Letter> -SteamPath <Steam-Path>`.
