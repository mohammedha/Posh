#requires -version 5
<#
.SYNOPSIS
    Uninstall specific versions of .NET Core Apps from the system.

.DESCRIPTION
    This script uninstalls specific versions of .NET Core Apps from the system. 
    It searches for installed versions based on a predefined list and uninstalls them using their respective BundleCachePath. 
    The script also includes logging functionality to track the uninstallation process.

.PARAMETER <Parameter_Name>
    None

.INPUTS
    None

.OUTPUTS Log File
    The script log file stored in C:\Temp\Uninstall--DotNetCoreApp_<ScriptDate>.log

.NOTES
    Version:        1.0.0
    Author:         Mohamed Hassan
    Creation Date:  22.10.2025
    Purpose/Change: Uninstall specific versions of .NET Core Apps from the system with logging functionality.

.EXAMPLE
    PS C:\> .\Uninstall-DotNetCore.ps1
    This will execute the script to uninstall the specified versions of .NET Core Apps and log the process.
.LINK
    https://github.com/mohammedha/Posh
#>


#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
    #Script parameters go here
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#----------------------------------------------------------[Declarations]----------------------------------------------------------

$ScriptVersion = "1.0.0"
$ScriptDate = "22.10.2025"
$date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
#-----------------------------------------------------------[Functions]------------------------------------------------------------
function Initialize-Log {
    <#
    .SYNOPSIS
        Initialize the log file.
    .DESCRIPTION
        This function will initialize the log file by creating the folder and file if they don't exist, or by clearing the log file if it does exist.

        The function will also write the header to the log file if the -IncludeHeader switch is used.
    .PARAMETER FilePath
        The path to the log file.
    .PARAMETER Clear
        Clear the log file.
    .PARAMETER IncludeHeader
        Include the header in the log file.
    .PARAMETER Passthru
        Pass the log file path through the pipeline.
    .EXAMPLE
        PS C:\> Initialize-Log -FilePath "C:\logs\log.txt" -Clear -IncludeHeader
        This will clear the log file and write the header to it.
    .LINK
        https://clebam.github.io/2018/02/10/Mastering-a-Write-Log-function/
    #>
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
    <#
    .SYNOPSIS
        Write a message to the log file.
    .DESCRIPTION
        This function will write a message to the log file with the specified level (Info, Warning, Error).
        The function will also include the date, time and the name of the script that called the function.
    .PARAMETER FilePath
        The path to the log file.
    .PARAMETER Message
        The message to be written to the log file.
    .PARAMETER Level
        The level of the message (Info, Warning, Error). Default is Info.
    .EXAMPLE
        Write-Log -FilePath $LogFile -Message "Hello Multiverse"
        This will write a message to the log file with the level Info.
    .EXAMPLE
        Get-ChildItem -Path C:\Temp -Recurse | Write-Log -FilePath $LogFile
        This will write the output of Get-ChildItem to the log file from the pipeline.
    .LINK
        https://clebam.github.io/2018/02/10/Mastering-a-Write-Log-function/
    #>
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
        
    }
    
    process {
        try {
            start-process -FilePath $FilePath -ArgumentList $ArgsList -NoNewWindow -Wait -Verbose
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

$Versions = @(
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
    "3.1.10.29419")
$Script:UninstallKeysList = @()

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
        write-Log -FilePath $LogFile -Message "Uninstalling DotNet CoreApp: $item" -Level "Info"
        Uninstall-BundleCache -FilePath $item
    }
    catch {
        Write-Log -FilePath $LogFile -Message "Failed to uninstall DotNet CoreApp: $item" -Level "Error"
        Write-Verbose "Failed to uninstall DotNet CoreApp: $item"
    }
}