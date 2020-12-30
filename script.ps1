function Connect-To-Iscsi-Target {
    try {
        Connect-IscsiTarget -NodeAddress $Target.NodeAddress -ErrorAction Stop
    }
    catch {
        return $_.Exception.Message == "Das Ziel wurde bereits über eine iSCSI-Sitzung angemeldet.";
    }

    return true;
}

function Start-Steam {
    param (
        [Parameter(Mandatory = $true)][String]$SteamPath
    )
    
    Start-Process -FilePath $SteamPath
}

function Show-Question {
    param (
        [Parameter(Mandatory = $true)][String]$NodeAddress,
        [Parameter(Mandatory = $true)][String]$DriveLetter,
        [Parameter(Mandatory = $true)][String]$SteamPath
    )

    $Title = "iSCI Target `"Games`""
    $Answer = [System.Windows.Forms.MessageBox]::Show("The connection to the iSCSI target/mounted drive cannot be established at the moment.", $Title, 2, [System.Windows.Forms.MessageBoxIcon]::Error)
    switch ($Answer) {
        "Retry" {
            Connect-To-Iscsi-Target
            Get-Iscsi-Status
        }
        "Ignore" {
            Start-Steam -SteamPath $SteamPath
        }
        Default {
            exit
        }
    }
}

function Wait-For-Drive-Mount {
    param (
        [Parameter(Mandatory = $true)][String]$DriveLetter
    )
    $Attempts = 0;
    do {
        $DriveMounted = [System.IO.Directory]::Exists($DriveLetter)
        $Attempts++
        Start-Sleep -s 3
    } until ($DriveMounted -or $Attempts -lt 3)

    return $DriveMounted
}

function Wait-For-Iscsi-Target {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][String]$NodeAddress
    )
    $Attempts = 0
    do {
        $Target = Get-IscsiTarget -NodeAddress $NodeAddress
        $Attempts++
        Start-Sleep -s 5
    } until ($Target.IsConnected -or $Attempts -lt 6)

    return $Target.IsConnected
}

function Get-Iscsi-Status {
    param (
        [Parameter(Mandatory = $true)][String]$NodeAddress,
        [Parameter(Mandatory = $true)][String]$DriveLetter,
        [Parameter(Mandatory = $true)][String]$SteamPath
    )
    if (Wait-For-Iscsi-Target -NodeAddress $NodeAddress) {
        if (Wait-For-Drive-Mount -DriveLetter $DriveLetter) {
            Start-Steam -SteamPath $SteamPath
        }
        else {
            Show-Question -NodeAddress $NodeAddress -DriveLetter $DriveLetter -SteamPath $SteamPath
        }
    }
    else {
        Show-Question -NodeAddress $NodeAddress -DriveLetter $DriveLetter -SteamPath $SteamPath
    }
}

param (
    [Parameter(Mandatory = $true)][String]$NodeAddress,
    [Parameter(Mandatory = $true)][String]$DriveLetter,
    [Parameter(Mandatory = $false)][String]$SteamPath = "C:\Program Files (x86)\Steam\steam.exe"
)

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-File $PSCommandPath" -Verb RunAs -WindowStyle Hidden;
    exit
}

Add-Type -AssemblyName System.Windows.Forms
$OriginalValue = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"
Get-Iscsi-Status -NodeAddress $NodeAddress -DriveLetter $DriveLetter -SteamPath $SteamPath
$ErrorActionPreference = $originalValue
