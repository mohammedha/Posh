
 Param(
    [Parameter(Mandatory=$true)]
    [String]$SiteSrv,      
    [Parameter(Mandatory=$false)]
    [String]$SiteNamespace,
    [Parameter(Mandatory=$True)]
    [String]$PackageID
)


$SiteCode = $SiteNamespace.Substring(14)

Write-Host "Checking" $PackageID -ForegroundColor red
Write-host "Will check for Installed Failed status (3) and Validation Failed (8)"
Write-Host ""

$sOpt = New-CimSessionOption –Protocol DCOM
$SiteServerCIM = New-CimSession -ComputerName $SiteSrv -SessionOption $sOpt

$DPs =  Get-CimInstance -CimSession $SiteServerCIM -Namespace $SiteNamespace -ClassName SMS_PackageStatusDistPointsSummarizer -Filter "PackageID = '$($PackageID)' AND (State = '3' OR State = '8')"
    
if ($DPs -ne $null)
{
    $Count = $DPs |measure 
    Write-Host "There are $($Count.count) failed DPs at the moment."
    Write-Host "Press any key to redistribute..."
    Write-Host ""
    $a = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    foreach ($dp in $DPs) {
        Write-Host "Redistributing $($DP.PackageID) to $($DP.ServerNALPath.Substring(12,7))...." -ForegroundColor Green
        try {

         Get-CimInstance -CimSession $SiteServerCIM -Namespace $SiteNamespace -ClassName SMS_DistributionPoint -Filter "PackageID='$($DP.PackageID)' and ServerNALPath like '%$($DP.ServerNALPath.Substring(12,7))%'" | Set-CimInstance -Property @{RefreshNow = $true}
        }
        catch {
            Write-Host "Failed to redistribute to $($DP.ServerNALPath.Substring(12,7))" -ForegroundColor Red
        }

    }
    Write-Host "Press any key to close window...."
    $a = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
else
{
    Write-Host "There are no Failed DPs" -ForegroundColor Green
    Write-Host "Press any key to close..."
    $a = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

}

Remove-CimSession -CimSession $SiteServerCIM
