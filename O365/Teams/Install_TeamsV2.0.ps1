#requires -version 4
<#
.SYNOPSIS
  Installs the Teams client on machines in the domain.

.DESCRIPTION
  This script installs the Microsoft Teams client on machines in the domain.

.PARAMETER None
  This script does not require any parameters.

.INPUTS
  None

.OUTPUTS
  None

.NOTES
  Version:        1.0
  Author:         Mohamed Hassan
  Creation Date:  24.03.2024
  Purpose/Change: Initial script development
  URI: https://github.com/mohammedha/Posh/tree/main

.EXAMPLE
  .\Install_TeamsV2.0.ps1
  The script will install the Teams client on all machines in the domain.
#>
#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
    #Script parameters go here
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Any Global Declarations go here
$Path = $PWD.Path

#-----------------------------------------------------------[Functions]------------------------------------------------------------

function Get-InstalledTeamsVersion {
    $AppName = "Teams Machine-Wide Installer"
    $InstallEntries = Get-ItemProperty  "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"  | Select-Object DisplayName, DisplayVersion, UninstallString | Where-Object { $_.DisplayName -match "^*$appname*" }
    
    if ($Null -eq $InstallEntries) {
        Write-Output "[$((Get-Date).TimeofDay)] [Info] No 'Teams Machine-Wide Installer' Installed"
        $Global:MachineWide = 0
    }
    else {
        #return $installEntries[0]
        Write-Output $InstallEntries[0]
    }
}
function Uninstall-MachineWideInstaller {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        #cmd /c "MsiExec.exe /qn /norestart /X{731F6BAA-A986-45A4-8936-7C3AAAAA760B}"
        $Process = "C:\Windows\System32\msiexec.exe"
        $ArgsList = '/qn /norestart /L*v $Global:Log /X{731F6BAA-A986-45A4-8936-7C3AAAAA760B}'
    }
    
    process {
        $process = Start-Process -FilePath $Process -Wait -PassThru -ArgumentList $ArgsList
        if ($process.ExitCode -ne 0) {
            Write-Output "[$((Get-Date).TimeofDay)] [Error] Encountered error while running uninstaller!." 
            #exit {{1}}
        }
        else {
            Write-Output "[$((Get-Date).TimeofDay)] [Info] Uninstallation complete." 
            #exit {{0}}
        }
    }
    
    end {
        
    }
}
function Reset-Bootstrapper {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        $Process = ".\teamsbootstrapper.exe"
        $ArgsList = '-x'
    }
    
    process {
        $process = Start-Process -FilePath $Process -Wait -PassThru -ArgumentList $ArgsList
        if ($process.ExitCode -ne 0) {
            Write-Output "[$((Get-Date).TimeofDay)] [Info] Encountered error while running uninstaller!." 
            #exit 1
        }
        Write-Output "[$((Get-Date).TimeofDay)] [Info] Reset complete." 
        #exit 0
    }
    
    end {
        try {
            Write-Output "[$((Get-Date).TimeofDay)] [Info] Removing Team registry entries"
            Remove-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\Office\Teams'
        }
        catch {
            Write-Output "[$((Get-Date).TimeofDay)] [Info] NO registry entries exist."
        }
        
    }
}
Function Start-Log {
    [Cmdletbinding(Supportsshouldprocess)]
    Param (
        [Parameter(Mandatory = $True)]
        [String]$FilePath,
        [Parameter(Mandatory = $True)]
        [String]$FileName
    )
	

    Try {
        If (!(Test-Path $FilePath)) {
            ## Create the log file
            New-Item -Path "$FilePath" -ItemType "directory" | Out-Null
            New-Item -Path "$FilePath\$FileName" -ItemType "file"
        }
        Else {
            New-Item -Path "$FilePath\$FileName" -ItemType "file"
        }
		
        ## Set the global variable to be used as the FilePath for all subsequent Write-Log calls in this session
        $global:ScriptLogFilePath = "$FilePath\$FileName"
    }
    Catch {
        Write-Error $_.Exception.Message
        Exit
    }
}
Function Write-Log {
    [Cmdletbinding(Supportsshouldprocess)]
    Param (
        [Parameter(Mandatory = $True)]
        [String]$Message,
		
        [Parameter(Mandatory = $False)]
        # 1 == "Informational"
        # 2 == "Warning'
        # 3 == "Error"
        [ValidateSet(1, 2, 3)]
        [Int]$LogLevel = 1,
        [Parameter(Mandatory = $False)]
        [String]$LogFilePath = $ScriptLogFilePath,
        [Parameter(Mandatory = $False)]
        [String]$ScriptLineNumber
    )

    $TimeGenerated = "$(Get-Date -Format HH:mm:ss).$((Get-Date).Millisecond)+000"
    $Line = '<![LOG[{0}]LOG]!><time="{1}" date="{2}" component="{3}" context="" type="{4}" thread="" file="">'
    $LineFormat = $Message, $TimeGenerated, (Get-Date -Format MM-dd-yyyy), "$ScriptLineNumber", $LogLevel
    $Line = $Line -f $LineFormat

    #Add-Content -Path $LogFilePath -Value $Line
    Out-File -InputObject $Line -Append -NoClobber -Encoding Default -FilePath $ScriptLogFilePath
}
Function Receive-Output {
    Param(
        $Color,
        $BGColor,
        [int]$LogLevel,
        $LogFile,
        [int]$LineNumber
    )

    Process {
        
        If ($BGColor) {
            Write-Host $_ -ForegroundColor $Color -BackgroundColor $BGColor
        }
        Else {
            Write-Host $_ -ForegroundColor $Color
        }

        If (($LogLevel) -or ($LogFile)) {
            Write-Log -Message $_ -LogLevel $LogLevel -LogFilePath $ScriptLogFilePath -ScriptLineNumber $LineNumber
        }
    }
}
Function AddHeaderSpace {
    
    Write-Output "This space intentionally left blank..."
    Write-Output ""
    Write-Output ""
    Write-Output ""
    Write-Output ""
    Write-Output ""
    Write-Output ""
}
function Test-RegPath {
    [CmdletBinding()]
    param (
        $RegPath = "HKLM:\Software\Wow6432Node\Microsoft\Office\Teams"
    )
    
    begin {
        
    }
    
    process {
        if (Test-Path $RegPath) {
            Write-Output "[$((Get-Date).TimeofDay)] [Info] Registry Path Exists, deleting..."
            Remove-Item -Path $RegPath
            if (Test-Path $RegPath) {
                Write-Output "[$((Get-Date).TimeofDay)] [Error] Registry Path Still Exists, Reg path remove failed."
            }
            else {
                Write-Output "[$((Get-Date).TimeofDay)] [Info] Registry Path Deleted, continuing..."
            }
        }
        else {
            Write-Output "[$((Get-Date).TimeofDay)] [Info] Registry Path Does Not Exist, continuing..."
        }
    }
    
    end {
        
    }
}
function Test-Prerequisites {
    [CmdletBinding()]
    param (
        [string]$Prerequisite 
    )
    
    begin {
        
    }
    
    process {
        Write-Output "[$((Get-Date).TimeofDay)] [Info] Finding Prerequisite [$Prerequisite]..."
        $File = (Get-ChildItem -Path . | Where-Object { $_.name -match $Prerequisite }).FullName
        if ($null -eq $File) {
            Write-Output "[$((Get-Date).TimeofDay)] [Error] Failed to find $Prerequisite, exiting..."
        }
        else {
            Write-Output "[$((Get-Date).TimeofDay)] [Info] Found: $File."
        }
    }
    
    end {
        
    }
}
function Get-TeamsMSIX {
    [CmdletBinding()]
    param (
        [switch]$x64,
        [switch]$x86
    )
    
    begin {
        $WebClient = New-Object System.Net.WebClient
        $MSTeams_x64 = "https://go.microsoft.com/fwlink/?linkid=2196106"
        $MSTeams_x86 = "https://go.microsoft.com/fwlink/?linkid=2196060"
    }
    
    process {
        if ($x64) {
            Write-Output "[$((Get-Date).TimeofDay)] [Info] Downloading Teams x64 installer..."
            $link = $MSTeams_x64
            #invoke-webrequest -Uri $link -OutFile ".\MSTeams-x64.msix"
            $WebClient.DownloadFile($link, "$PWD/MSTeams-x64.msix")
        }
        if ($x86) {
            Write-Output "[$((Get-Date).TimeofDay)] [Info] Downloading Teams x86 installer..."
            $link = $MSTeams_x86
            #invoke-webrequest -Uri $link -OutFile ".\MSTeams-x86.msix"
            $WebClient.DownloadFile($link, "$PWD/MSTeams-x86.msix")
        }
    }
    
    end {
        Write-Output "[$((Get-Date).TimeofDay)] [Info] Testing downloaded files..."
        Test-prerequisites -prerequisite "msteams"
    }
}
function Get-TeamsBootstrapper {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        $WebClient = New-Object System.Net.WebClient
        $BootStrapperLink = "https://go.microsoft.com/fwlink/?linkid=2243204"
    }
    
    process {
        Write-Output "[$((Get-Date).TimeofDay)] [Info] Downloading Teams Bootstrapper..."
        $WebClient.DownloadFile($BootStrapperLink, "$PWD/teamsbootstrapper.exe")
    }
    
    end {
        Write-Output "[$((Get-Date).TimeofDay)] [Info] Testing downloaded files..."
        Test-prerequisites -prerequisite "teamsbootstrapper.exe"
    }
}
function Install-TeamsV2 {
    [CmdletBinding()]
    param (
        [switch]$x64,
        [switch]$x86
    )
    
    begin {
        $D = Get-Date -Format yyyy-MM-dd
        $Bootstrapper = "$PWD/teamsbootstrapper.exe"
        $LogFile = "C:\Windows\Temp\TeamsV2.log"
        if ($x64) {
            $ArgsList = '-p -o "c:\temp\MSTeams-x64.msix"'
        }
        if ($x86) {
            $ArgsList = '-p -o "c:\temp\MSTeams-x86.msix"'
        }
    }
    
    process {
        $process = Start-Process -FilePath $Bootstrapper -Wait -PassThru -ArgumentList $ArgsList
        if ($process.ExitCode -ne 0) {
            Write-Output "[$((Get-Date).TimeofDay)] [Error] Encountered error while running installer!." 
            #exit { { 1 } }
        }
        Write-Output "[$((Get-Date).TimeofDay)] [Info] Installation complete." 
        #exit { { 0 } }
    }
    
    end {
        # copy Bootstrapper log file from C:\Windows\Temp folder to C:\Temp\Logs folder
        try {
            Copy-Item C:\Windows\Temp\teamsprovision.$D.log -Destination "C:\Temp\logs" -force
            Write-Output "[$((Get-Date).TimeofDay)] [Info] 'C:\Windows\Temp\teamsprovision.$D.log' copied to 'C:\Temp\logs'."
        }
        catch {
            Write-Output "[$((Get-Date).TimeofDay)] [Info] Unable to copy 'teamsprovision.$D.log' to C:\Temp\logs"
        }
    }
}
function Remove-OldTeamsFolders {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        $Folders = (Get-ChildItem "C:\users" -Directory -Exclude "Default", "Public", "lansweeper.service")
        Write-Output "[$((Get-Date).TimeofDay)] [Info] Found $($Folders.Count) user profile(s)."
        $folders | Receive-Output -Color Gray -LogLevel 1
    }
    
    process {
        
        foreach ($Item in $Folders.Name) {
            try {
                if (Test-Path "C:\Users\$item\AppData\Local\Microsoft\Teams") {
                    Write-Output "Deleting Teams folder from $Item's profile."
                    $count = (Get-ChildItem C:\Users\$item\AppData\Local\Microsoft\Teams -Force -Recurse).count
                    Remove-Item -Path "C:\Users\$item\AppData\Local\Microsoft\Teams" -Force -Recurse -Verbose -ErrorAction Stop
                    Write-Output "[$((Get-Date).TimeofDay)] [Info] $count file(s) deleted from $Item's profile Teams folder."
                    Write-Output "----------------------------------------------------------------"
                }
                else {
                    Write-Output "[$((Get-Date).TimeofDay)] [Info] Teams folder not found in $Item's profile."
                }
            }
            catch {
                Write-Output "Unable to Delete Teams folder from $Item's profile."
                write-output $PSItem.Exception.Message
            }        
        }
    }
    
    end {
        
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# Start logging
$Global:Date = Get-Date -Format "dd.MM.yyyy"
$Global:DateNTime = Get-Date -Format "dd.MM.yyyy-HH-mm-ss"
$Global:logFolder = "C:\Temp\Logs"
$Global:LogFileName = "Log--Install_TeamsV2---$DatenTime.log"
$Global:Log = $logfolder + "\" + $LogFilename
Start-Log -FilePath $LogFolder -FileName $LogFileName | Out-Null
Write-Output "[$((Get-Date).TimeofDay)] [Info] Script start: $StartTime" | Receive-Output -Color white -LogLevel 1
Write-Output "[$((Get-Date).TimeofDay)] [Info] Creating log Folder/File" | Receive-Output -Color white -LogLevel 1 
$ErrorActionPreference = "Stop"
Write-Output "[$((Get-Date).TimeofDay)] [Info] Running $($MyInvocation.MyCommand.Path)..." | Receive-Output -Color white -LogLevel 1

# Uninstall Teams
Get-InstalledTeamsVersion | Receive-Output -Color white -LogLevel 1
if ($Global:MachineWide -ne 0) {
    Uninstall-MachineWideInstaller | Receive-Output -Color white -LogLevel 1
}
Set-Location "C:\Temp"

# Clean up
Remove-OldTeamsFolders  | Receive-Output -Color Gray -LogLevel 1
Test-RegPath | Receive-Output -Color white -LogLevel 1

# Download Prerequisites
Get-TeamsBootstrapper | Receive-Output -Color white -LogLevel 1
Get-TeamsMSIX -x64 | Receive-Output -Color white -LogLevel 1

# Install Teams
Install-TeamsV2 -x64 | Receive-Output -Color white -LogLevel 1

