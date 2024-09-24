
function Get-CBCAlert {
    <#
    .SYNOPSIS
        Retrieve alerts from Carbon Black Cloud based on a user-selected time range.

    .DESCRIPTION
        This PowerShell script interacts with the Carbon Black Cloud (CBC) API to retrieve alerts based on a user-selected time range. It displays the alerts in a grid view for easy analysis.

    .EXAMPLE
        Get-CBCAlert -minimum_severity 5 -range -2w | out-gridview
        This command will retrieve the all alerts in the last 2 weeks with severity greater than or equal to 5 from Carbon Black Cloud then display it in gridview.

    .EXAMPLE
        Get-CBCAlert | out-gridview
        This command will retrieve the all alerts in the last 1 day from Carbon Black Cloud then display it in gridview.
    
    .EXAMPLE
        Get-CBCAlert -All | out-gridview
        This command will retrieve all alerts from Carbon Black Cloud then display it in gridview.

    .OUTPUTS
        [PSCustomObject]
        The script outputs a grid view of the retrieved alerts, including details such as ID, detection timestamp, severity, device name, reason, and more.

    .NOTES
        Written by Mohamed Hassan
        I take no responsibility for any issues caused by this script.

    .FUNCTIONALITY
        - Set up global variables for Carbon Black Cloud credentials and API endpoint.
        - Validate user input to ensure a valid choice is made.
        - Construct the body of the API request with the selected time range and other criteria.
        - Send the API request to retrieve alerts and process the response.
        - Display the retrieved alerts in a grid view, sorted by severity.

    .LINK
        https://developer.carbonblack.com/reference/carbon-black-cloud/platform/latest/alerts-api/
    #>
    [CmdletBinding()]
    param (
        [validateSet("-1d", "-3d", "-1w", "-2w", "-1m", "-3m")]
        $Range = '-1d',
        $search,
        [int]$rows = 10000,
        [int]$start = 1,
        [ValidateSet("ASC", "DESC")]
        [string]$order = "ASC",
        [int]$MinimumSeverity,
        [ValidateSet("Windows", "Mac", "Linux")]
        [string[]]$OS,
        [switch]$All
    )
    
    begin {
        $Global:OrgKey = "ORGGKEY"                                              # Add your org key here
        $Global:APIID = "APIID"                                                 # Add your API ID here
        $Global:APISecretKey = "APISECRETTOKEN"                                 # Add your API Secret token here
        $Global:Hostname = "https://defense-xx.conferdeploy.net"                # Add your CBC URL here
        $Global:Headers = @{"X-Auth-Token" = "$APISecretKey/$APIID" }
        $Global:Uri = "$Hostname/api/alerts/v7/orgs/$OrgKey/alerts/_search"

    }
    
    process {
        $jsonBody = "{
        
    }"
        $psObjBody = $jsonBody |  ConvertFrom-Json
        if ($search) { $psObjBody | Add-Member -Name "search" -Value $search -MemberType NoteProperty }  
        if ($Range) {
            $psObjBody | Add-Member -Name "time_range" -Value ([PSCustomObject]@{}) -MemberType NoteProperty
            $psObjBody.time_range | Add-Member -Name "range" -Value $Range -MemberType NoteProperty
        }
        if ($start) { $psObjBody | Add-Member -Name "start" -Value $start -MemberType NoteProperty }
        if ($rows) { $psObjBody | Add-Member -Name "rows" -Value $rows -MemberType NoteProperty }
        
        if ($order) {
            $psObjBody | Add-Member -Name "sort" -Value @([PSCustomObject]@{}) -MemberType NoteProperty
            $psObjBody.sort | Add-Member -Name "field" -Value "severity" -MemberType NoteProperty
            $psObjBody.sort | Add-Member -Name "order" -Value $order -MemberType NoteProperty
        }
        if ($Minimumseverity -or $OS) {
            $psObjBody | Add-Member -Name "criteria" -Value ([PSCustomObject]@{}) -MemberType NoteProperty
            if ($OS) { $psObjBody.criteria | Add-Member -Name "device_os" -Value @($OS) -MemberType NoteProperty }
            if ($MinimumSeverity) { $psObjBody.criteria | Add-Member -Name "minimum_severity" -Value $MinimumSeverity -MemberType NoteProperty }
        }
        if ($All) {
            $psObjBody | Add-Member -Name "rows" -Value $rows -MemberType NoteProperty
            $psObjBody | Add-Member -Name "start" -Value $start -MemberType NoteProperty
        }
        $jsonBody = $psObjBody | ConvertTo-Json
        $Response = Invoke-WebRequest -Uri $Uri -Headers $Headers -Method Post -Body $jsonBody -ContentType "application/json"
        $Data = $Response.Content | Convertfrom-Json
    }
    
    end {
        $Data.results
    }
}