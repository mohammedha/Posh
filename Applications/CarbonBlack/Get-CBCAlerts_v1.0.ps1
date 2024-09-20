#Requires -Version 6.0

Clear-Host
$Global:OrgKey = "ORGGKEY"                                              # Add your org key
$Global:APIID = "APIID"                                                 # Add your API ID
$Global:APISecretKey = "APISECRETTOKEN"                                 # Add your API Secret token
$Global:Hostname = "https://defense-xx.conferdeploy.net"                # Add your CBC URL
$Global:Headers = @{"X-Auth-Token" = "$APISecretKey/$APIID" }
$Global:Uri = "$Hostname/api/alerts/v7/orgs/$OrgKey/alerts/_search"

# Menu
Write-Output "Please choose the alerts time range: "
$List = '1 Day', '3 Days', '1 Week', '2 Weeks', '1 Month', '3 Months', 'Exit'
foreach ($MenuItem in $List) {
    '{0} - {1}' -f ($List.IndexOf($MenuItem) + 1), $MenuItem
}

$Choice = ''
while ([string]::IsNullOrEmpty($Choice)) {
    Write-Host
    $Choice = Read-Host 'Please choose an item by number '
    if ($Choice -notin 1..$List.Count) {
        [console]::Beep(1000, 300)
        ('    Your choice [ {0} ] is not valid.' -f $Choice)
        ('        The valid choices are 1 thru {0}.' -f $List.Count)
        '        Please try again ...'
        pause
        $Choice = ''
    }
    elseif ($Choice -eq 2) {
        Return
    }
}

"`nYou chose {0}" -f $List[$Choice - 1]
$Range = $List[$Choice - 1]

switch ($Range) {
    "1 Day" { $Range = "-1d" }
    "3 Days" { $Range = "-3d" }
    "1 Week" { $Range = "-1w" }
    "2 Weeks" { $Range = "-2w" }
    "1 Month" { $Range = "-30d" }
    "3 Months" { $Range = "-180d" }
}

$Global:Body = @{
    "time_range" = @{
        "range" = $Range
    }
    "criteria"   = @{
        "minimum_severity" = 1
    }
    "start"      = "1"
    "rows"       = "10000"
}

# Get Alerts
$Response = Invoke-WebRequest -Uri $Uri -Headers $Headers -Method Post -Body ($Body | ConvertTo-Json) -ContentType "application/json"
$Data = $Response.Content | Convertfrom-Json
$Data.results | Select-Object -Property id, detection_timestamp, severity, device_name, reason, reason_code, policy_applied, run_state, sensor_action, device_policy, `
    device_os, device_os_version, device_username, device_external_ip, device_internal_ip, ttps, process_name, process_reputation | Sort-Object -Descending severity | Out-GridView


