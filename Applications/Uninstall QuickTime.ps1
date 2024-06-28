<# 
Apple QuickTime Player
Version	    Product Code
7.55.90.70	{8DC42D05-680B-41B0-8878-6C14D24602DB}
7.65.17.80	{8B7917E0-AF55-4E8A-9473-017F0AA03AC8}
7.66.71.0   {28BE306E-5DA6-4F9C-BDB0-DBA3C8C6FFFD}
7.68.75.0	{E7004147-2CCA-431C-AA05-2AB166B9785D}
7.69.80.9	{57752979-A1C9-4C02-856B-FBB27AC4E02C}
7.70.80.34	{C9E14402-3631-4182-B377-6B0DFB1C0339}
7.71.80.42	{7BE15435-2D3E-4B58-867F-9C75BED0208C}
7.72.80.56	{0E64B098-8018-4256-BA23-C316A43AD9B0}
7.73.80.64	{AF0CE7C0-A3E4-4D73-988B-B29187EC6E9A}
7.74.80.86	{B67BAFBA-4C9F-48FA-9496-933E3B255044}
7.75.80.95	{111EE7DF-FC45-40C7-98A7-753AC46B12FB}
7.76.80.95	{3D2CBC2C-65D4-4463-87AB-BB2C859C1F3E}
7.77.80.95	{627FFC10-CE0A-497F-BA2B-208CAC638010}
7.78.80.95	{80CEEB1E-0A6C-45B9-A312-37A1D25FDEBC}
7.79.80.95	{FF59BD75-466A-4D5A-AD23-AAD87C5FD44C}
#>

#----------------------------------------------------------[Declarations]----------------------------------------------------------

$Global:Date = Get-Date -Format "dd.MM.yyyy"
$Global:DateNTime = Get-Date -Format "dd.MM.yyyy-HH-mm-ss"
$Global:logFolder = "C:\Temp"
$Global:LogFileName = "Log--Uninstall_QucikTime--$Date.log"
$Global:Log = $LogFolder + "\" + $LogFilename
$QTVERSION = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  | Get-ItemProperty | Where-Object { $_.DisplayName -match "quicktime" }
#Regex for GUID
$ReGuid = '\{?(([0-9a-f]){8}-([0-9a-f]){4}-([0-9a-f]){4}-([0-9a-f]){4}-([0-9a-f]){12})\}?'
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
Write-Output "[$((Get-Date).TimeofDay)] Script start: $StartTime" | Receive-Output -Color Gray -LogLevel 1
Write-Output "[$((Get-Date).TimeofDay)] Creating log Folder/File" | Receive-Output -Color Gray -LogLevel 1 

#-----------------------------------------------------------[Execution]------------------------------------------------------------
# enumerate QuickTime installations
Write-Output "[$((Get-Date).TimeofDay)] Enumerating QuickTime installations..." | Receive-Output -Color Gray -LogLevel 1
if ($QTVERSION) {
    return $QTVERSION
}
else {
    Write-Output "[$((Get-Date).TimeofDay)] No QuickTime installations found." | Receive-Output -Color Gray -LogLevel 1
}



foreach ($Version in $QTVERSION) {
    try {
        If ($Version.UninstallString) {
            $ID = if ($version.UninstallString -match $reGuid) { $Matches[0] }
            Write-Output "[$((Get-Date).TimeofDay)] Uninstalling $($Version.DisplayName) with '$ID'..." | Receive-Output -Color Gray -LogLevel 1
            $Arg = ("/uninstall " + $ID + " /norestart /quiet /log `"$logFileName`"")
            $process = Start-Process msiexec.exe -ArgumentList $Arg -Wait -NoNewWindow -PassThru
            if ($process.ExitCode -eq 0) {
                Write-Output ($Version.DisplayName + " was successfully uninstalled") -ForegroundColor Green | Receive-Output -Color White -LogLevel 1
            }
            else {
                Write-Output ($Version.DisplayName + " was not successfully uninstalled, msiexec process returned ExitCode: " + $process.ExitCode + ", please check the log file at: $logFile") | Receive-Output -Color Red -LogLevel 3
            }
        }
    }
    catch {
        Write-Output "[$((Get-Date).TimeofDay)] Error: $($_.Exception.Message)" | Receive-Output -Color Red -LogLevel 3
    }
    
}

