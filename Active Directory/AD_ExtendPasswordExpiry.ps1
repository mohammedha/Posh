<#
.Synopsis
	This Script Will Reset The Password Last Reset Date "Pwdlastset"

.Description
    This Script Will 
    - Set "Pwdlastset" To 0 | This Will Expires The Password Immediately.
    - Set "Pwdlastset" To -1 | This Will Set The Password Last Set To Today.
    

.Note
    - Rdp To A Dc
    - Run Script In Powershell Ise As Admin
    - Follow The Prompt

    Author: Mohamed Hassan
	Last Modified: 11/02/2020
#>

# Script Information
Write-Host "-------------------------------------------------------------" -Backgroundcolor White
Write-Host
Write-Host "Extend Password Expiry Date Script" -Foregroundcolor Green
Write-Host "Version: 1.0.0" -Foregroundcolor Green
Write-Host 
Write-Host "Authors:" -Foregroundcolor Green
Write-Host "Mohamed Hassan  | Https://Github.Com/Mohammedha/Powershell " -Foregroundcolor Green
Write-Host
Write-Host "-------------------------------------------------------------" -Backgroundcolor White
Write-Host


$Dc = Read-host RPlease Type your FQDN for a domain Controller:FQDN for your domain controller"
# Assign 0 To The Pwdlastset Attribute, This Expires The Password Immediately.
$User = Read-Host "Please Enter The Username"
Set-Aduser -Server $Dc -Identity "$User" -Replace @{Pwdlastset = 0 } -Verbose

# Wait For 30 Seconds
Write-Verbose "Pausing For 10 Seconds"
Start-Sleep -Seconds 10

# Assign -1 To The Pwdlastset Attribute, This Will Set The Last Set Date To Today And The Password Olicy Will Start Counting From Today.
Set-Aduser -Server $Dc -Identity "$User" -Replace @{Pwdlastset = -1 } -Verbose

#$Newlastsetdate = Get-Aduser -Identity $User -Server $Dc -Properties Pwdlastset | Select @{Name = "Newpwdlastset"; Expression = { $([Datetime]::Fromfiletime($_.Pwdlastset)) } }
$Newexpirydate = Get-Aduser -Identity $User -Server $Dc -Properties Pwdlastset | Select @{Name = "Newexpirydate"; Expression = { $([Datetime]::Fromfiletime($_.Pwdlastset)).Adddays(42) } }

#$Newlastsetdate
$Newexpirydate
