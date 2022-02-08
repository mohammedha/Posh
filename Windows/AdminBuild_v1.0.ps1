
<#
    .Synopsis
        Install Essential Admin tools
    .DESCRIPTION
        Install Essential Admin tools
        - Create log
        - Install RSAT
        - Install Powershell modules
        - Create default powershell profile for All Users / All Hosts
        - Install Chocolatey
        - Install 3rd party tools [notepadplusplus googlechrome 7zip winscp openssh git Firefox Cmder ConEmu fiddler osquery putty rdmfree javaruntime jre8 curl adobereader angryip irfanview imgburn superorca]
        - Install MS tools [orca sysinternals vscode vscode-powershell microsoft-windows-terminal dotnet dotnet3.5 sccmtoolkit]
        - Install MS Sql tools [sql-server-management-studio dbatools]
        - Install MS online tools [sql-server-management-studio dbatools]
        - Install SpecOps
        - Enable the Windows Subsystem for Linux v2 [Unbuntu and Kali]
    .NOTES
       Written by Mohamed Hassan
       I take no responsibility for any issues caused by this script.
    .LINK
       https://github.com/mohammedha/Posh
    #>

#-------------------------------------------------
# logging
#-------------------------------------------------
try {
    New-Item -Path C:\ -Name Temp -ItemType Directory
}
catch {
    Write-Host "Temp folder already exist" -ForegroundColor Yellow
}

$lf = "C:\Temp\Logs\"
$DatenTime = ((Get-Date).toString('dd.MM.yyyy-HHmm'))
$LogFilename = $env:USERNAME + '-' + $DatenTime + '.' + 'txt'
$Log = $Lf + $LogFilename
function ensureLogFolder {
    if (!(Test-Path -Path $lf)) {
        $lfo = New-Item -Path $lf -ItemType Directory
    }
    return $lf
}
ensureLogFolder
function ensureLogFile {
    if (!(Test-Path -Path $log )) {
        New-Item -path $Log -ItemType File
    }
    return $LogFilename
}

#-------------------------------------------------
# Create log folder/file
#-------------------------------------------------
ensureLogFolder
ensureLogFile

#-------------------------------------------------
# Start Transcript
#-------------------------------------------------
Write-Host "Start Logging..." -ForegroundColor Yellow
Start-Transcript -path $Log

#-------------------------------------------------
# Preparation
#-------------------------------------------------
Set-PSRepository PSGallery -InstallationPolicy Trusted
Set-ExecutionPolicy RemoteSigned -Force

#-------------------------------------------------
# Install RSAT
#-------------------------------------------------
Write-Host "Installing Remote Server Administrative Tools..." -ForegroundColor Yellow
Get-WindowsCapability -Name RSAT* -Online  | Add-WindowsCapability -Online

#-------------------------------------------------
# Install Powershell modules
#-------------------------------------------------
Write-Host "Installing Powershell Modules..." -ForegroundColor Yellow
Install-Module -Name VMware.PowerCLI 
Install-Module -Name carbon
Install-Module -Name scclient
Install-Module -Name ntfssecurity
Install-Module -Name PSWriteColor
Install-Module -Name AzureAD
Install-Module -Name MSOnline

#-------------------------------------------------
# Chocolatey
#-------------------------------------------------
Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-WebRequest -uri "https://chocolatey.org/install.ps1" -UseBasicParsing | Invoke-Expression
Choco install chocolatey-gui -y

#-------------------------------------------------
# Essential tools
#-------------------------------------------------
Write-Host "Installing Essential Tools..." -ForegroundColor Yellow
Choco install notepadplusplus googlechrome 7zip winscp openssh git Firefox Cmder ConEmu fiddler osquery putty rdmfree javaruntime jre8 curl adobereader angryip irfanview imgburn superorca -y

#-------------------------------------------------
# Microsoft Tools
#-------------------------------------------------
Write-Host "Installing Microsoft Tools..." -ForegroundColor Yellow
Choco install orca sysinternals vscode vscode-powershell microsoft-windows-terminal dotnet dotnet3.5 sccmtoolkit -y

#-------------------------------------------------
# SQL Related
#-------------------------------------------------
Write-Host "Installin SQL Tools..." -ForegroundColor Yellow
Choco install sql-server-management-studio dbatools -y

#-------------------------------------------------
# Cloud - Azure / Office365
#-------------------------------------------------
Write-Host "Installing Azure/MSOnline tools..." -ForegroundColor Yellow
Choco install azure-cli azcopy msoid-cli -y

#-------------------------------------------------
# Vmware related
#-------------------------------------------------
Write-Host "Installing vmWare Tools..." -ForegroundColor Yellow
Choco install rvtools vmware-tools -y
Set-PowerCLIConfiguration -Scope AllUsers -ParticipateInCEIP $false -confirm:$false

#-------------------------------------------------
# SpecOps
#-------------------------------------------------
Write-Host "Installing GPO Specops..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://download.specopssoft.com/Release/gpupdate/specopsgpupdatesetup.exe" -OutFile C:\Temp\specops.exe
7z x C:\Temp\specops.exe -oC:\Temp\SpecOps\
Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList '/i "C:\Temp\SpecOps\Products\SpecOpsGPUpdate\SpecopsGpupdate-x64.msi" /qb' -Wait

#-------------------------------------------------
# Cleanup
#-------------------------------------------------
#Remove-Item -Path C:\Temp\* -Recurse -Force

#-------------------------------------------------
# Enable the Windows Subsystem for Linux
#-------------------------------------------------
Write-Host "Enabling the Windows Subsystem for Linux..." -ForegroundColor Yellow
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

#-------------------------------------------------
# Enable Virtual Machine feature
#-------------------------------------------------
Write-Host "Enabling Virtual Machine feature..." -ForegroundColor Yellow
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

#-------------------------------------------------
# Set WSL v2 as default
#-------------------------------------------------
Write-Host "Configuring WSL..." -ForegroundColor Yellow
wsl --set-default-version 2

#-------------------------------------------------
# Install Ubuntu 20.04
#-------------------------------------------------
Write-Host "Installing Ubuntu 20.04 Linux ..." -ForegroundColor Yellow
Invoke-WebRequest -Uri https://aka.ms/wslubuntu2004 -OutFile wslubuntu2004.appx -UseBasicParsing
Add-AppxPackage .\wslubuntu2004.appx

#-------------------------------------------------
# Install Kali
#-------------------------------------------------
Write-Host "Installing Kali Linux..." -ForegroundColor Yellow
Invoke-WebRequest -Uri  https://aka.ms/wsl-kali-linux-new -OutFile wsl-kali-linux-new.appx -UseBasicParsing
Add-AppxPackage .\wsl-kali-linux-new.appx

#-------------------------------------------------
# Create default powershell profile for All Users / All Hosts
#-------------------------------------------------
$Ask = Read-Host -Prompt "Do you want to create Powershell Profile?[y/n]"
if ($Ask -eq "y") {
    Copy-Item -Path "\\Path\to\Profile\Microsoft.PowerShell_profile_20-08-2021_current.ps1" $PROFILE.AllusersAllHosts    
}

#-------------------------------------------------
# Stop Transcript
#-------------------------------------------------
Stop-Transcript

#-------------------------------------------------
# Reboot to complete installation
#-------------------------------------------------
Write-Host "Restarting..." -ForegroundColor Yellow
#Restart-Computer
