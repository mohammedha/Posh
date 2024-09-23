
function Get-CBCAlerts {
    [CmdletBinding()]
    param (
        [parameter(HelpMessage = "Accepted range values are: -1d, -3d, -1w, -2w, -1m, -3m")]
        [validateSet("-1d", "-3d", "-1w", "-2w", "-1m", "-3m")]
        $Range = '-1d'
    )
    
    begin {
        $Global:OrgKey = "ORGGKEY"                                              # Add your org key here
        $Global:APIID = "APIID"                                                 # Add your API ID here
        $Global:APISecretKey = "APISECRETTOKEN"                                 # Add your API Secret token here
        $Global:Hostname = "https://defense-xx.conferdeploy.net"                # Add your CBC URL here

    }
    
    process {
        $Global:Headers = @{"X-Auth-Token" = "$APISecretKey/$APIID" }
        $Global:Uri = "$Hostname/api/alerts/v7/orgs/$OrgKey/alerts/_search"
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
    }
    
    end {
        $Data.results | Select-Object -Property id, detection_timestamp, severity, device_name, reason, reason_code, policy_applied, run_state, sensor_action, device_policy, `
            device_os, device_os_version, device_username, device_external_ip, device_internal_ip, ttps, process_name, process_reputation | Sort-Object -Descending severity | Out-GridView

    }
}