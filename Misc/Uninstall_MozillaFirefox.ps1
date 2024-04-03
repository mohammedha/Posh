

# Functions
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
function GetInstalledVersion {
    $appName = "Mozilla Firefox"
    $installEntries = Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' | Select-Object DisplayName, DisplayVersion, UninstallString | Where-Object { $_.DisplayName -match "^*$appname*" }
    
    if ($installEntries.Length -eq 0) {
        return $null
    }
    return $installEntries[0]
}
function Uninstall($RegistryEntry) {
    $uninstallString = $RegistryEntry.UninstallString
    $uninstallExe = $uninstallString.trim('"')
    $arguments = '/S'
    Write-Output "Uninstalling Mozilla Firefox with version $($installedVersion.DisplayVersion)..."
    $process = Start-Process -FilePath $uninstallExe -Wait -PassThru -ArgumentList $arguments -Verbose
    if ($process.ExitCode -ne 0) {
        Write-Output "Encountered error while running uninstall!"
        exit 1
    }
}

# Start logging
$Global:Date = Get-Date -Format "dd.MM.yyyy"
$Global:DateNTime = Get-Date -Format "dd.MM.yyyy-HH-mm-ss"
$Global:logFolder = "C:\Temp\Logs"
$Global:LogFileName = "Log--Uninstall_Firefox---$DatenTime.log"
$Global:Log = $logfolder + "\" + $LogFilename
Start-Log -FilePath $LogFolder -FileName $LogFileName | Out-Null
Write-Output "[$((Get-Date).TimeofDay)] Script start: $StartTime" | Receive-Output -Color white -LogLevel 1
Write-Output "[$((Get-Date).TimeofDay)] Creating log Folder/File" | Receive-Output -Color white -LogLevel 1

$ErrorActionPreference = "Stop"
Write-Output "Running $($MyInvocation.MyCommand.Path)..." | Receive-Output -Color white -LogLevel 1

Write-Output "Checking for installed versions of Desktop Connector..." | Receive-Output -Color white -LogLevel 1
# Search the registry for an installed version of Desktop Connector
$installedVersion = GetInstalledVersion
if ($null -eq $installedVersion) {
    Write-Output "No versions of Mozilla Firefox were found installed on this machine" | Receive-Output -Color Yellow -LogLevel 2
    exit 0
}
Write-Output "Detected installed version of Mozilla Firefox with version $($installedVersion.DisplayVersion)..." | Receive-Output -Color white -LogLevel 1
    
# Obtain the uninstall string and execute the process
Uninstall $installedVersion | Receive-Output -Color white -LogLevel 1
Write-Output "Desktop Connector uninstalled"