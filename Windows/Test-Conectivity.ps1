# A quick utility for checking if you're online
# Checks interfaces, gateway, DNS, conntectivity
# Inspired by Alicia Sykes Bash script:https://github.com/Lissy93/dotfiles/blob/master/utils/am-i-online.sh

$Success = " `u{221A} "
$Fail = " `u{AB59} "
$Genral = "`u{2588}`u{2593}`u{2592}`u{2591}"
$reset = "`e[0m"

function Test-HttpHost {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string]$Uri
    )
    try {
        invoke-webrequest -uri $Uri -SkipHeaderValidation | Out-Null
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Output "Error: no active internet connection"
        exit 1
    }

}

function Test-DNS {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $DNSHost
    )
    try {
        Test-NetConnection -ComputerName $DNSHost -Port 53 -InformationLevel Quiet | Out-Null
        Write-Host $Success -NoNewline  -ForegroundColor Green
        Write-Host "  DNS Online" -ForegroundColor Green
    }
    catch {
        Write-Host $Fail -NoNewline -ForegroundColor Red
        Write-Host "  DNS Offline" -ForegroundColor Red
    }

}

function Test-Gateway {
    [CmdletBinding()]
    param (
        
    )
    $GW = (get-netroute -DestinationPrefix 0.0.0.0/0).NextHop
    if (Test-Connection $GW -Count 1 -BufferSize 8 -Quiet) {
        Write-Host $Success -NoNewline  -ForegroundColor Green
        Write-Host "  Gateway Online" -ForegroundColor Green
    }
    else {
        Write-Host $Fail -NoNewline -ForegroundColor Red
        Write-Host "  Gateway Offline" -ForegroundColor Red
    }

}

function Test-URL {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Uri
    )
    try {
        if ((Invoke-WebRequest -Uri $uri -Method Head).StatusCode -eq 200) {
            Write-Host $Success -NoNewline  -ForegroundColor Green
            Write-Host "  Domains Online" -ForegroundColor Green
        }
    }
    catch {
        Write-Host $Fail -NoNewline -ForegroundColor Red
        Write-Host "  Domains Offline" -ForegroundColor Red
    }
}

function Test-Interfaces {
    [CmdletBinding()]
    param (
        
    )
    try {
        $state = (Get-NetIPInterface | ? { $_.addressfamily -eq 'ipv4' -and $_.InterfaceAlias -like 'ether*' }).ConnectionState
        if ($state -eq 'Connected') {
            Write-Host $Success -NoNewline  -ForegroundColor Green
            Write-Host "  Interfaces configured" -ForegroundColor Green
        }
    }
    catch {
        Write-Host $Fail -NoNewline -ForegroundColor Red
        Write-Host "  Interfaces not configured" -ForegroundColor Red
    }
}

function Start-Test {
    <#
.SYNOPSIS
Start-Test is a PowerShell function that tests connectivity.

.DESCRIPTION
The Start-Test function tests various connectivity aspects such as DNS, gateway, URL, and interfaces. It uses other functions to perform these tests.

.EXAMPLE
PS> Start-Test

#>
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        $line = "`u{2500}" * 30
        Clear-Host
    }
    
    process {
        Write-Host $Line
        Write-Host $Genral -NoNewline
        Write-Host " Testing connectivity..." -ForegroundColor Green
        Write-Host $Line
        Test-DNS -DNSHost 1.1.1.1
        Test-Gateway
        Test-URL -Uri "https://duck.com"
        Test-Interfaces
        Write-Host $Line
    }
    
    end {
        
    }
}

