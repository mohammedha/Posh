

#----------------------------------------------------------[Declarations]----------------------------------------------------------

$Global:Date = Get-Date -Format "dd.MM.yyyy"
$Global:DateNTime = Get-Date -Format "dd.MM.yyyy-HH-mm-ss"
$Global:logFolder = "C:\Temp"
$Global:LogFileName = "Log--Uninstall_Silverlight--$Global:DateNTime.log"
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
Write-Output "[$((Get-Date).TimeofDay)] Script start: $Global:DateNTime." | Receive-Output -Color Gray -LogLevel 1
Write-Output "[$((Get-Date).TimeofDay)] Creating log Folder/File." | Receive-Output -Color Gray -LogLevel 1 

#-----------------------------------------------------------[Execution]------------------------------------------------------------
#(Get-WmiObject -Class Win32_Product -Filter "Name='Microsoft Silverlight'" -ComputerName . ).Uninstall()

try {
    Write-Output "[$((Get-Date).TimeofDay)] Finding Microsoft Silverlight installation..." | Receive-Output -Color Gray -LogLevel 1
    $Global:MSL = Get-CimInstance -Class Win32_Product -Filter "Name='Microsoft Silverlight'" 
    $Global:MSL | ForEach-Object -Process { Invoke-CimMethod -InputObject $_ -MethodName Uninstall }
    if ($Global:MSL.ReturnValue -eq 0) {
        Write-Output "[$((Get-Date).TimeofDay)] Name: $($Global:MSL.Name)." | Receive-Output -Color Gray -LogLevel 1
        Write-Output "[$((Get-Date).TimeofDay)] IdentifyingNumber: $($Global:MSL.IdentifyingNumber)." | Receive-Output -Color Gray -LogLevel 1
        Write-Output "[$((Get-Date).TimeofDay)] Version: $($Global:MSL.Version)." | Receive-Output -Color Gray -LogLevel 1
        Write-Output "[$((Get-Date).TimeofDay)] Microsoft Silverlight Uninstalled." | Receive-Output -Color Gray -LogLevel 1
    }
}
catch {
    Write-Output "[$((Get-Date).TimeofDay)] Microsoft Silverlight is not installed." | Receive-Output -Color White -LogLevel 1
}
