#requires -version 5
<#
.SYNOPSIS
    Uninstall specific versions of .NET Core Apps from the system.
.DESCRIPTION
    This script uninstalls specific versions of .NET Core Apps from the system.
    It searches for installed versions based on user-specified or predefined list and uninstalls them using their respective BundleCachePath.
    The script also includes logging functionality to track the uninstallation process.
.PARAMETER Versions
    Specifies the .NET Core versions to uninstall. If not provided, the script uses a default list.
.INPUTS
    None
.OUTPUTS Log File
    The script log file stored in C:\Temp\Uninstall--DotNetCoreApp_<ScriptDate>.log
.NOTES
    Version:        1.0.1
    Author:         Mohamed Hassan
    Creation Date:  24.10.2025
    Purpose/Change: Uninstall specific versions of .NET Core Apps from the system with logging functionality and parameterized versions.
.EXAMPLE
    PS C:\> .\Uninstall-DotNetCore.ps1 -Versions "7.0.7.32525", "6.0.36.34217"
    This will execute the script to uninstall the specified versions of .NET Core Apps and log the process.
.EXAMPLE
    PS C:\> .\Uninstall-DotNetCore.ps1
    This will execute the script to uninstall the default list of .NET Core Apps and log the process.
.LINK
    https://github.com/mohammedha/Posh
#>

Param (
    [Parameter(Mandatory = $false)]
    [string[]]$Versions = @(
        "7.0.7.32525",
        "7.0.5",
        "7.0.20.33720",
        "7.0.20",
        "7.0.0.31819",
        "6.0.8.31518",
        "6.0.36.34217",
        "6.0.36.34214",
        "6.0.33",
        "6.0.26",
        "6.0.10",
        "5.0.17",
        "5.0.16",
        "3.1.32.31915",
        "3.1.32",
        "3.1.30",
        "3.1.24",
        "3.1.10.29419"
    )
)

#----------------------------------------------------------[Declarations]----------------------------------------------------------
$ScriptVersion = "1.0.1"
$ScriptDate = "24.10.2025"
$date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ErrorActionPreference = 'SilentlyContinue'
$Script:UninstallKeysList = @()

#-----------------------------------------------------------[Functions]------------------------------------------------------------

function Initialize-Log {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,
        [switch]$Clear,
        [switch]$IncludeHeader,
        [switch]$Passthru
    )
    if (-not(Test-Path -Path $FilePath)) {
        New-Item -Path $FilePath -Force | Out-Null
    }
    if ($Clear) {
        Clear-Content -Path $FilePath
    }
    if ($IncludeHeader) {
        [string[]]$Header = @()
        $Header += "$("#" * 50)"
        $Header += "# Running script : $($MyInvocation.ScriptName)"
        $Header += "# Start time : $(Get-Date)"
        $Header += "# Executing account : $([Security.Principal.WindowsIdentity]::GetCurrent().Name)"
        $Header += "# ComputerName : $env:COMPUTERNAME"
        $Header += "$("#" * 50)"
        $Header | Out-File -FilePath $FilePath -Append
    }
    if ($Passthru) {
        Write-Output $FilePath
    }
}

function Write-Log {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript({
                if (-not (Test-Path $_)) {
                    throw "The file $_ does not exist. Use Initialize-Log to create it."
                }
                $true
            })]
        [string]$FilePath,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error")]
        $Level = "Info"
    )
    Process {
        $FormattedDate = Get-Date -Format "[yyyy-MM-dd][HH:mm:ss]"
        $OutString = "$FormattedDate - $Level - $Message"
        $OutString | Out-File -FilePath $FilePath -Append
        switch ($Level) {
            "Info" { Write-Host $OutString; break }
            "Warning" { Write-Host $OutString -ForegroundColor Yellow; break }
            "Error" { Write-Host $OutString -ForegroundColor Red; break }
            Default { Write-Host $OutString; break }
        }
    }
}

function Get-UninstallKey {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$AppName
    )
    $UninstallReg1 = Get-ChildItem -Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall -ErrorAction SilentlyContinue  | Get-ItemProperty | Where-Object { $_ -match $AppName }
    if ($UninstallReg1) {
        Return $UninstallReg1
    }
    else {
        Return $null
    }
}

function Uninstall-BundleCache {
    [CmdletBinding()]
    param (
        $FilePath = $BundleCachePath,
        $ArgsList = "/uninstall /quiet"
    )

    begin {
        # Initialization code, if any
    }

    process {
        try {
            Start-Process -FilePath $FilePath -ArgumentList $ArgsList -NoNewWindow -Wait -Verbose
        }
        catch {
            Write-Log -FilePath $LogFile -Message "Failed to uninstall using BundleCachePath: $FilePath" -Level "Error"
        }
    }

    end {
        Write-Log -FilePath $LogFile -Message "Uninstallation process completed for BundleCachePath: $FilePath" -Level "Info"
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# start logging
$LogFile = Initialize-Log -FilePath "C:\Temp\Uninstall--DotNetCoreApp_$date.log" -IncludeHeader -Clear -Passthru

foreach ($item in $Versions) {
    if (!(Get-UninstallKey -AppName $item )) {
        Write-Verbose "No uninstall key found for version $item"
        Write-Log -FilePath $LogFile -Message "No uninstall key found for version $item" -Level "Info"
        continue
    }
    else {
        Write-Verbose "Uninstall key(s) found for version $item"
        $Script:uninstallKeysList += Get-UninstallKey -AppName $item
    }
}

Write-Log -FilePath $LogFile -Message "Total DotNet CoreApp(s) found for uninstallation: $($Script:uninstallKeysList.Count)" -Level "Info"

if ($Script:uninstallKeysList.Count -eq 0) {
    Write-Log -FilePath $LogFile -Message "No DotNet CoreApp(s) found for uninstallation, exiting..." -Level "Info"
    exit
}
else {
    Write-Verbose "Total DotNet CoreApp(s) found for uninstallation: $($Script:uninstallKeysList.Count)"
    Write-Log -FilePath $LogFile -Message "Starting uninstallation process..." -Level "Info"
}

# Uninstall all found DotNet CoreApp(s)
foreach ($item in $Script:uninstallKeysList.BundleCachePath) {
    try {
        Write-Log -FilePath $LogFile -Message "Uninstalling DotNet CoreApp: $item" -Level "Info"
        Uninstall-BundleCache -FilePath $item
    }
    catch {
        Write-Log -FilePath $LogFile -Message "Failed to uninstall DotNet CoreApp: $item" -Level "Error"
        Write-Verbose "Failed to uninstall DotNet CoreApp: $item"
    }
}
