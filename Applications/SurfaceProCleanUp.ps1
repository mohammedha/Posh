

#----------------------------------------------------------[Declarations]----------------------------------------------------------

$Global:Date = Get-Date -Format "dd.MM.yyyy"
$Global:DateNTime = Get-Date -Format "dd.MM.yyyy-HH-mm-ss"
$Global:logFolder = "C:\Temp"
$Global:LogFileName = "Log--CleanupSurfaceProTerminal--$Global:DateNTime.log"
$Global:Log = $Global:LogFolder + "\" + $Global:LogFilename

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
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

# start logging
$LogFile = Initialize-Log -FilePath $Global:Log -IncludeHeader -Clear -Passthru

Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Hostname $($env:COMPUTERNAME)." 
Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] User: $($env:USERNAME)." 
Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Create log Folder/File: $Global:Log." 
Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Start log: $Global:DateNTime." 

#-----------------------------------------------------------[Execution]------------------------------------------------------------
# Uninstall Silverlight
try {
    Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Finding Microsoft Silverlight installation..." 
    $Global:MSL = Get-CimInstance -Class Win32_Product -Filter "Name='Microsoft Silverlight'" 
    foreach ($Item in $Global:MSL) {
        Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Uninstalling $item." 
        Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Name: $($item.Name)." 
        Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] IdentifyingNumber: $($item.IdentifyingNumber)." 
        Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Version: $($item.Version)." 
        $Uninstall = Invoke-CimMethod -InputObject $item -MethodName Uninstall -Verbose
        if ($($uninstall.ReturnValue) -eq 0) {
            Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] $($item.Name) Successfully Uninstalled." 
        }
    }
}
catch {
    Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Microsoft Silverlight is not installed." 
}

# Uninstall Windows Appx
try {
    Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Finding Microsoft AppxPackges installation..." 
    $SearchTerms = @('outlookforwindows', 'MicrosoftOfficeHub', 'MicrosoftSolitaireCollection', 'WindowsStore', 'MSTeams')
    $Apps = @()
    foreach ($Term in $SearchTerms) {
        $App = Get-AppxPackage -AllUsers | Where-Object { $_.name -match $Term }
        foreach ($PackageFullName in $($App.PackageFullName) ) {
            $Apps = $Apps + $PackageFullName
        }
    }
    foreach ($Application in $Apps) {
        Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Removing Appx package: $Application"
        Remove-AppxPackage -Package $Application -AllUsers -Verbose
        if ($?) {
            Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Appx package: $Application removed successfully."
        } 
    }
}
catch {
    Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Removing Appx package: $Application failed."
}

# Uninstall Microsoft Teams Meeting Add-on
try {
    Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Uninstalling Microsoft Teams Meeting Add-on..."
    Start-Process -FilePath msiexec -ArgumentList '/x {A7AB73A3-CB10-4AA5-9D38-6AEFFBDE4C91} /q' -Verbose
    Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Microsoft Teams Meeting Add-on uninstallation completed."
}
catch {
    Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Microsoft Teams Meeting Add-on uninstallation failed."
}

# Uninstall Microsoft Office 365 Apps C2R
try {
    Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Uninstalling Microsoft Office 365 Apps C2R..."
    Start-Process -FilePath .\Setup.exe -ArgumentList '/configure .\All.xml' -Verbose -Wait
    Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Microsoft Office 365 Apps C2R uninstallation completed."
}
catch {
    Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Microsoft Office 365 Apps C2R uninstallation failed."
}

# Cleanup desktop icons
try {
    Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Cleaning up desktop icons..."
    $Icons = [environment]::getfolderpath('CommonDesktopDirectory')
    Get-ChildItem $Icons | Remove-Item -Exclude 'Omnissa Horizon Client.lnk'
}
catch {
    Write-Log -FilePath $LogFile -Message "[$((Get-Date).TimeofDay)] Cleaning up desktop icons failed."
}


