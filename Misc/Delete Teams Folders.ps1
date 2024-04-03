
#----------------------------------------------------------[Declarations]----------------------------------------------------------

$Global:Date = Get-Date -Format "dd.MM.yyyy"
$Global:DateNTime = Get-Date -Format "dd.MM.yyyy-HH-mm-ss"
$Global:logFolder = "C:\Temp"
$Global:LogFileName = "Log--DeleteTeamsFolder--$Global:DateNTime.log"
$Global:Log = $Global:LogFolder + "\" + $Global:LogFilename

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
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
Start-Log -FilePath $LogFolder -FileName $LogFileName | Out-Null
Write-Output "[$((Get-Date).TimeofDay)] Hostname $($env:COMPUTERNAME)." | Receive-Output -Color Gray -LogLevel 1 
Write-Output "[$((Get-Date).TimeofDay)] User: $($env:USERNAME)." | Receive-Output -Color Gray -LogLevel 1 
Write-Output "[$((Get-Date).TimeofDay)] Create log Folder/File: $Global:Log." | Receive-Output -Color Gray -LogLevel 1 
Write-Output "[$((Get-Date).TimeofDay)] Start log: $Global:DateNTime." | Receive-Output -Color Gray -LogLevel 1

#-----------------------------------------------------------[Execution]------------------------------------------------------------

$Computer = ($env:COMPUTERNAME).ToUpper()
$SessionList = quser /Server:$Computer 2>$null
if ($SessionList) {
    $UserInfo = foreach ($Session in ($SessionList | Select-Object -Skip 1)) {
        $Session = $Session.ToString().trim() -replace '\s+', ' ' -replace '>', ''
        if ($Session.Split(' ')[3] -eq 'Active') {
            [PSCustomObject]@{
                ComputerName = $Computer
                UserName     = $session.Split(' ')[0]
                SessionName  = $session.Split(' ')[1]
                SessionID    = $Session.Split(' ')[2]
                SessionState = $Session.Split(' ')[3]
                IdleTime     = $Session.Split(' ')[4]
                LogonTime    = $session.Split(' ')[5, 6, 7] -as [string] -as [datetime]
            }
        }
        else {
            [PSCustomObject]@{
                ComputerName = $Computer
                UserName     = $session.Split(' ')[0]
                SessionName  = $null
                SessionID    = $Session.Split(' ')[1]
                SessionState = 'Disconnected'
                IdleTime     = $Session.Split(' ')[3]
                LogonTime    = $session.Split(' ')[4, 5, 6] -as [string] -as [datetime]
            }
        }
    }
}

$Folders = (Get-ChildItem "c:\users" -Directory -Exclude "Default", "Public", "lansweeper.service", $($UserInfo.username)).name
$folders | Receive-Output -Color Gray -LogLevel 1

foreach ($Item in $Folders) {
    try {
        Write-Output "Deleting Teams folder from $Item's profile." | Receive-Output -Color Gray -LogLevel 1
        Remove-Item -Path "C:\Users\$item\AppData\Local\Microsoft\Teams" -Force -Recurse -Verbose -ErrorAction Stop | Receive-Output -Color Gray -LogLevel 1
        Write-Output "----------------------------------------------------------------" | Receive-Output -Color Gray -LogLevel 1
    }
    catch {
        Write-Output "Unable to Delete Teams folder from $Item's profile." | Receive-Output -Color Gray -LogLevel 1
        write-output $PSItem.Exception.Message | Receive-Output -Color Gray -LogLevel 1
    }
    
}
