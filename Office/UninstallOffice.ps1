<#
    .Synopsis
        Uninstall Office 
    .DESCRIPTION
        This script will uninstall all installed office versions [M365, 2021, 2019, 2016, 2013, 2010 and 2007].
    .OUTPUTS
        Text file "output.txt" with the tool output.
    .FUNCTIONALITY
       This script will uninstall all installed office versions [M365, 2021, 2019, 2016, 2013, 2010 and 2007], 
       it will...
       - Download the latest SaRA_Enterprise version
       - Run "SaRAcmd.exe"
       - Create a txt file "Output.txt" with all tool output.
    .NOTES
       Written by Mohamed Hassan
       I take no responsibility for any issues caused by this script.
    .LINK
       https://github.com/mohammedha/Posh
       https://learn.microsoft.com/en-us/microsoft-365/troubleshoot/administration/sara-command-line-version
    #>

# Check if Elevated
$WindowsIdentity = [system.security.principal.windowsidentity]::GetCurrent()
$Principal = New-Object System.Security.Principal.WindowsPrincipal($WindowsIdentity)
$AdminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

if ($Principal.IsInRole($AdminRole)) {
    Write-Host -ForegroundColor Green "Elevated PowerShell session detected. Continuing."
}
else {
    Write-Host -ForegroundColor Red "Autodesk License Support Tool must be run in an elevated PowerShell window. Please launch an elevated session and try again."
    Break
}

#Variable
$LogFolder = "C:\temp\saRACmd"
$SupportToolFolder = "C:\temp\saRACmd\SaRA_Enterprise"
$SupportTool = "SaRA_Enterprise.zip"

# Script

# Create log folder if doesn't exist
if (!(Test-Path $LogFolder)) {
    Write-Information -MessageData "Creating Log folder..." -Verbose -InformationAction Continue
    New-Item -ItemType Directory -Name saRACmd -Path "C:\temp\"
}
else {
    Write-Information "$LogFolder Does Exist - OK" -verbose -InformationAction Continue
}
# Download/Extract saRACmd tool 
Set-Location -Path $LogFolder
Invoke-WebRequest -Uri https://aka.ms/SaRA_EnterpriseVersionFiles -OutFile "SaRA_Enterprise.zip"
Expand-Archive -Path $SupportTool -Force
Set-Location -Path $SupportToolFolder
# Uninstall all installed Office versions
cmd /c "SaRAcmd.exe -S OfficeScrubScenario -AcceptEula -CloseOffice -OfficeVersion All >>$LogFolder\Output.txt"
