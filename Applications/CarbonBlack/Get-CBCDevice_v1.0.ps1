
function Get-CBCDevice {
    <#
    .SYNOPSIS
        Retrieve device information from Carbon Black Cloud using the Alert API.

    .DESCRIPTION
        This function interacts with the Carbon Black Cloud (CBC) Alert API to retrieve device information based on a user-selected criteria. It displays the devices in a grid view for easy analysis.

    .EXAMPLE
        PS C:\> $device = Get-CBCDevice -Search "W10*"
        PS C:\> $device | ft -AutoSize

        This command will search for devices with hostname starting with "W10" and return the results in a grid view.

    .EXAMPLE
        PS C:\> $device = Get-CBCDevice -DeploymentType ENDPOINT -OS WINDOWS
        PS C:\> $device | ft -AutoSize

        This command will search for devices with deployment type "ENDPOINT" and OS "WINDOWS" and return the results in a grid view.

    .EXAMPLE
        PS C:\> $device = Get-CBCDevice -DeploymentType ENDPOINT -OS WINDOWS -PolicyName "Standard"
        PS C:\> $device | ft -AutoSize

        This command will search for devices with deployment type "ENDPOINT", OS "WINDOWS", and policy name "Standard" and return the results in a grid view.

    .NOTES
        Written by Mohamed Hassan
        I take no responsibility for any issues caused by this script.

    .FUNCTIONALITY
        - Set up global variables for Carbon Black Cloud credentials and API endpoint.
        - Validate user input to ensure a valid choice is made.
        - Convert the user's choice into a time range format suitable for the API request.
        - Construct the body of the API request with the selected time range and other criteria.
        - Send the API request to retrieve devices and process the response.
        - Display the retrieved devices in a grid view, sorted by severity.

    .LINK
        https://developer.carbonblack.com/reference/carbon-black-cloud/platform/latest/alerts-api/
    #>

    [CmdletBinding()]
    param (
        $search,
        [int]$rows,
        [int]$start,
        [ValidateSet("ASC", "DESC")]
        [string]$order = "ASC",
        [validateset("ENDPOINT", "WORKLOAD", "AZURE", "GCP", "AWS", "VDI")]
        [string[]]$DeploymentType,
        [ValidateSet("WINDOWS", "LINUX", "MAC")]
        [string[]]$os,
        [int[]]$policyID,
        [string[]]$policyName,
        [version]$sensorVersion,
        [bool]$Quarantined,
        [switch]$All
    )
    
    begin {
        $Global:OrgKey = "ORGGKEY"                                              # Add your org key here
        $Global:APIID = "APIID"                                                 # Add your API ID here
        $Global:APISecretKey = "APISECRETTOKEN"                                 # Add your API Secret token here
        $Global:Hostname = "https://defense-xx.conferdeploy.net"                # Add your CBC URL here
        $Global:Headers = @{"X-Auth-Token" = "$APISecretKey/$APIID" }
        $Global:Uri = "$Hostname/appservices/v6/orgs/$OrgKey/devices/_search"

    }
    
    process {
        $jsonBody = "{
        
    }"
        $psObjBody = $jsonBody |  ConvertFrom-Json   
        if ($Search) { $psObjBody | Add-Member -Name "query" -Value $Search -MemberType NoteProperty }
        if ($rows) { $psObjBody | Add-Member -Name "rows" -Value $rows -MemberType NoteProperty }
        if ($start) { $psObjBody | Add-Member -Name "start" -Value $start -MemberType NoteProperty }
        if ($order) { $psObjBody | Add-Member -Name "order" -Value $order -MemberType NoteProperty }
        if ($All) { 
            $psObjBody | Add-Member -Name "rows" -Value 10000 -MemberType NoteProperty
            $psObjBody | Add-Member -Name "start" -Value 0 -MemberType NoteProperty
        }
        
        if ($DeploymentType -or $OS -or $PolicyID -or $PolicyName -or $SensorVersion -or $Quarantined) {
            $psObjBody | Add-Member -Name "criteria" -Value ([PSCustomObject]@{}) -MemberType NoteProperty
            
            if ($DeploymentType) { $psObjBody.criteria | Add-Member -Name "deployment_type" -Value @($DeploymentType) -MemberType NoteProperty }
            if ($PolicyID) { $psObjBody.criteria | Add-Member -Name "policy_id" -Value @($PolicyID) -MemberType NoteProperty }
            if ($PolicyName) { $psObjBody.criteria | Add-Member -Name "policy_name" -Value @($PolicyName) -MemberType NoteProperty }
            if ($SensorVersion) { $psObjBody.criteria | Add-Member -Name "sensor_version" -Value @($SensorVersion) -MemberType NoteProperty }
            if ($Quarantined) { $psObjBody.criteria | Add-Member -Name "quarantined" -Value @($Quarantined) -MemberType NoteProperty }
            if ($OS) { $psObjBody.criteria | Add-Member -Name "os" -Value @($OperatingSystem) -MemberType NoteProperty }
        }
        $jsonBody = $psObjBody | ConvertTo-Json
        $Response = Invoke-WebRequest -Uri $Uri -Headers $Headers -Method Post -Body $jsonBody -ContentType "application/json"
        $Data = $Response.Content | Convertfrom-Json
    }
    end {
        $Data.results
    }
}