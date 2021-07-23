<#
    .Synopsis
        Configure Autodesk products license to named USER license
    .DESCRIPTION
        This script will convert Autodesk licenses to the new Autodesk license model "Named Licenses" for all install Autodesk products.
    .OUTPUTS
        Text file "LicenseReset.txt" with the tool output.
    .FUNCTIONALITY
       This script will convert Autodesk licenses to the new Autodesk license model "Named Licenses" for all install Autodesk products, 
       it will...
       - Download AdskLicensingSupportTool
       - Run "AdskLicensingSupportTool.exe"
       - Create a txt file "LicenseReset.txt" with all tool output.
       - If the tool ran before and "LicenseReset.txt" exist it will not run again [to force running the tool again just delete the TXT file]
    .NOTES
       Written by Mohamed Hassan
       I take no responsibility for any issues caused by this script.
    .LINK
       https://github.com/mohammedha/Posh
       https://knowledge.autodesk.com/search-result/caas/downloads/content/licensing-support-tool.html
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
$ResetFile = "C:\Autodesk\AdskLicensingSupportTool\LicenseReset.txt"
$ADSKFolder = "C:\Autodesk\"
$SupportToolFolder = "C:\Autodesk\AdskLicensingSupportTool"
$SupportTool = "adsklicensingsupporttool-2.0.0.364-win.zip"

# Script
if (!(Test-Path -path $ResetFile)) {
    # Create Autodesk if doesn't exist
    if (!(Test-Path $ADSKFolder)) {
        Write-Information -MessageData "Creating Autodesk folder..." -Verbose -InformationAction Continue
        New-Item -ItemType Directory -Name Autodesk -Path "C:"
    }
    else {
        Write-Information "$ADSKFolder Does Exist - OK" -verbose -InformationAction Continue
    }
    # Download/Extract ADSK tool 
    Set-Location -Path $ADSKFolder
    Invoke-WebRequest -Uri https://download.autodesk.com/us/support/files/AdskLicensingSupportTool/adsklicensingsupporttool-2.0.0.364-win.zip -OutFile "adsklicensingsupporttool-2.0.0.364-win.zip"
    Expand-Archive -Path $SupportTool -Force
    Move-Item -LiteralPath "C:\Autodesk\adsklicensingsupporttool-2.0.0.364-win\AdskLicensingSupportTool" -Destination $ADSKFolder -Force
    Set-Location -Path $SupportToolFolder
    # Converting ADSK Products to Named User licenses
    # https://knowledge.autodesk.com/search-result/caas/downloads/content/licensing-support-tool.html
    cmd /k "AdskLicensingSupportTool.exe -r All:USER >>LicenseReset.txt"
    exit
}
else {
    Write-Information "AdskLicensingSupportTool Already Ran on this machine" -verbose -InformationAction Continue
    exit
}
