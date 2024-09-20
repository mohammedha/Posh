<#
.Synopsis
    Retrieve alerts from Carbon Black Cloud based on a user-selected time range.

.DESCRIPTION
    This PowerShell script interacts with the Carbon Black Cloud (CBC) API to retrieve alerts based on a user-selected time range. It displays the alerts in a grid view for easy analysis.

.EXAMPLE
    .\Get-CBAlerts.ps1

    This command will prompt the user to select a time range and retrieve the corresponding alerts from Carbon Black Cloud.

.OUTPUTS
    [PSCustomObject]
    The script outputs a grid view of the retrieved alerts, including details such as ID, detection timestamp, severity, device name, reason, and more.

.NOTES
    Written by Mohamed Hassan
    I take no responsibility for any issues caused by this script.

.FUNCTIONALITY
    - Set up global variables for Carbon Black Cloud credentials and API endpoint.
    - Display a menu for the user to choose the time range for alerts.
    - Validate user input to ensure a valid choice is made.
    - Convert the user's choice into a time range format suitable for the API request.
    - Construct the body of the API request with the selected time range and other criteria.
    - Send the API request to retrieve alerts and process the response.
    - Display the retrieved alerts in a grid view, sorted by severity.

.LINK
    https://developer.carbonblack.com/reference/carbon-black-cloud/platform/latest/alerts-api/
#>


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


