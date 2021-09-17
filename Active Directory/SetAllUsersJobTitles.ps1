
# Create log folder/file
$Global:Date = ((Get-Date).toString('dd.MM.yyyy'))
$Global:DatenTime = ((Get-Date).toString('dd.MM.yyyy-HHmm'))
$Global:logfolder = "\\Share\Logs\$Date\"
$Global:LogFilename = $env:USERNAME + '-' + $DatenTime + '.' + 'txt'
$Global:Log = $logfolder + $LogFilename

# Log file/folder
function New-logFolder {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    if (!(Test-Path -Path $logfolder)) {
        New-Item -Path $logfolder -ItemType Directory
    }
    return $logfolder
}
function New-LogFile {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    if (!(Test-Path -Path $log )) {
        New-Item -path $Log -ItemType File
    }
    return $LogFilename
}

Write-Verbose -Message "Setting up Log folder..." -Verbose
New-logFolder
Write-Verbose -Message "Creating up Log file..." -Verbose
New-LogFile

# Start Transcript
Start-Transcript -path $Log -Verbose

$Updates = Import-Csv -Path "K:\temp\Updated_Jobtitle.csv"
#$Updates = Import-Csv -Path "K:\temp\test.csv"

foreach ($Item in $Updates) {
    $Name = $Item.UserPrincipalName
    $JT = $Item.JobTitle
    $Dept = $Item.Department
    ""
    Write-Host "Configuring " $Name -ForegroundColor White
    write-host "Set " $Name " Jobtitle to:" $JT ", and Department is:" $Dept -ForegroundColor Yellow
    Set-qaduser $name -Title $JT -Department $Dept -verbose
}

Stop-Transcript -Verbose