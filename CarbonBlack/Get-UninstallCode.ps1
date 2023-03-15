<#
This Script will retrive the uninstall code for Carbonblack Cloud

#>
#Requires -Version 6.0


$Global:Computer = "Pc1"
$Global:OrgKey = "xxxxxxxx"
$Global:APIID = "xxxxxxxxxx"
$Global:APISecretKey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Global:Hostname = "https://defense-eu.conferdeploy.net"
$Global:Headers = @{"X-Auth-Token" = "$APISecretKey/$APIID" }
$Global:Body = @{
    "deployment_type" = "ENDPOINT"
    "query"           = "$Computer"
}
$Global:Uri = "$Hostname/appservices/v6/orgs/$OrgKey/devices/_search"
$Response = Invoke-WebRequest -Uri $Uri -Headers $Headers -Method Post -Body ($Body | ConvertTo-Json) -ContentType "application/json"
$Data = $Response.Content | Convertfrom-Json

Clear-Host
Write-Host "Uninstall Code for $Computer is: " -NoNewline
write-host $data.results.uninstall_code -ForegroundColor Yellow
