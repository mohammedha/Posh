$Date = Get-Date -Format "MM-dd-yyyy"

$LogFileName = "C:\temp\DHCPLeasesConversion_$date.log"
[ipaddress]$ScopeId = read-host -Prompt "Enter Scope ID"
$server = "ZH-BGL-DC21"

$leases = Get-DhcpServerv4Lease -ComputerName $server -ScopeId $ScopeId
if (!(Test-Path -Path $LogFileName)) { $Null = New-Item -Path $logFileName -ItemType file -Force }

foreach ($lease in $leases) {
    try {
        write-host "[$((Get-Date).TimeofDay)] INFO: Converting: $lease"
        Add-Content -Value "[$((Get-Date).TimeofDay)] LOG: Adding Hostname: $($lease.HostName), IP: $($lease.IPAddress), Client: $($lease.ClientId), Scope: $($lease.ScopeId)" -Path $LogFileName
        New-DhcpServerv4Reservation -IPAddress $lease.IPAddress -ClientId $lease.ClientId -ScopeId $lease.ScopeId -Description "Converted from DHCP lease" -verbose
    }
    catch {
        write-host "[$((Get-Date).TimeofDay)] ERROR: Failed to convert: $lease" -ForegroundColor Red
        Add-Content -Value "[$((Get-Date).TimeofDay)] ERROR: Failed to convert: $($lease.HostName), IP: $($lease.IPAddress), Client: $($lease.ClientId), Scope: $($lease.ScopeId)" -Path $LogFileName
    }
    
}

