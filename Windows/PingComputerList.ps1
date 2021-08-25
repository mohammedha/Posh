<#
.SYNOPSIS
    Ping multipl computer
.DESCRIPTION
    Ping multiple computer from a list, returing computer name and IP address if online
.EXAMPLE
    Get-Hostname -computername $PCs
.NOTE

#>


$PCs = Get-Content C:\temp\PCs.txt # path to computer names list
function Get-Hostname {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]    
        $computername
    )
    begin {
        Write-Host "Loading list" $PCs.count "name(s)"
    }
    process {
        $Y = 01
        Foreach ($PC in $PCs) { 
            $i = 1
            
            $perct = [math]::Round(($i / $PCs.count) * 100)
            Write-Progress -Activity "Testing Computer(s)" -Status "Pinging $PC" -PercentComplete $perct
            Start-Sleep -Milliseconds 50
            $i++
            try {
                if ((Test-Connection $PC -Count 1 -BufferSize 8 -Quiet) -eq $true) {
                    Write-Host $Y ": " -NoNewline;
                    Write-Host "PC: $pC --> " -NoNewline;
                    Write-Host "IP: --> " -NoNewline;
                    Write-Host ([System.Net.Dns]::GetHostByName($PC).addresslist.IPAddressToString) -ForegroundColor Green
                    #Write-Host ([System.Net.Dns]::GetHostEntry($PC).HostName) -ForegroundColor Green
                    $Y++
                }
            }
            catch {
                write-host "No such host is known or offline" -ForegroundColor Red
            }
        }
    }
}

Get-Hostname -computername $PCs





