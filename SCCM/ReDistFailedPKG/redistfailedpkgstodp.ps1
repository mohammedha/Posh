
 Param(
    [Parameter(Mandatory=$true)]
    [String]$SiteSrv,      
    [Parameter(Mandatory=$false)]
    [String]$SiteNamespace,
    [Parameter(Mandatory=$True)]
    [String]$Server
)


$SiteCode = $SiteNamespace.Substring(14)


Write-Host "Checking" $Server -ForegroundColor red
Write-host "Will check for all failed packages (NOT State 0)"
Write-Host ""

$sOpt = New-CimSessionOption –Protocol DCOM
$SiteServerCIM = New-CimSession -ComputerName $SiteSrv -SessionOption $sOpt
try {
        $pkgs =  Get-CimInstance -CimSession $SiteServerCIM -Namespace $SiteNamespace -ClassName SMS_PackageStatusDistPointsSummarizer -Filter "ServerNALPath like '%$($Server)%' AND (State != '0')"

        if ($pkgs -ne $null)
        {
            $Count = $pkgs |measure 
            Write-Host "There are $($Count.count) failed packages at the moment."
            Write-Host "Press any key to redistribute..."
            Write-Host ""
            $a = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            foreach ($pkg in $pkgs) {
                Write-Host "Redistributing $($pkg.PackageID) to $($Server)...." -ForegroundColor Green
                try {
    
                 Get-CimInstance -CimSession $SiteServerCIM -Namespace $SiteNamespace -ClassName SMS_DistributionPoint -Filter "PackageID='$($pkg.PackageID)' and ServerNALPath like '%$($Server)%'" | Set-CimInstance -Property @{RefreshNow = $true}
                }
                catch {
                    Write-Host "Failed to redistribute to $($pkg.ServerNALPath.Substring(12,7))" -ForegroundColor Red
                }

            }
            Write-Host "Press any key to close window...."
            $a = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        else
        {
            Write-Host "There are no Failed pkgs" -ForegroundColor Green
            Write-Host "Press any key to close..."
            $a = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        }

        Remove-CimSession -CimSession $SiteServerCIM

    }
Catch { 
    Write-Error "Failed to query $($Sitesrv)"
    Remove-CimSession -CimSession $SiteServerCIM
}

