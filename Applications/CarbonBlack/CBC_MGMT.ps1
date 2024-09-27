
<#
.SYNOPSIS
This PowerShell script is a collection of functions that interact with the Carbon Black Cloud (CBC) API to retrieve and display information about alerts, devices, policies, and uninstall codes. The script is designed to help administrators and security professionals manage their Carbon Black Cloud environment more efficiently.

.DESCRIPTION
This script provides a set of functions that allow users to retrieve information about alerts, devices, policies, and uninstall codes from Carbon Black Cloud. The functions use the Carbon Black Cloud API to retrieve data, and they display the data in a grid view for easy analysis. The script is well-documented with help comments that describe the purpose, parameters, examples, output, notes, functionality, and links to the relevant CBC API documentation for each function. The script is also formatted with a `Show-ScriptHelp` function that displays the script help information with colored output.

.NOTES
This script contains the following functions:

* `Get-CBCAlert`: Retrieves alerts from Carbon Black Cloud based on a user-selected time range. This function allows users to filter alerts by severity, operating system, and search criteria. The function returns a grid view of the retrieved alerts, including details such as ID, detection timestamp, severity, device name, reason, and more.
* `Get-CBCDevice`: Retrieves device information from Carbon Black Cloud using the API. This function allows users to filter devices by deployment type, operating system, policy ID, policy name, sensor version, and quarantined status. The function returns a grid view of the retrieved devices, including details such as name, ID, uninstall code, OS, policy name, and more.
* `Get-CBCPolicy`: Retrieves policies from Carbon Black Cloud. This function allows users to retrieve all policies in a summary view, or a detailed view of a policy specified by its ID or name. The function returns a table of the retrieved policies, including details such as ID, name, and description.
* `Get-CBCUninstallCode`: Retrieves the uninstall code for a specified computer from Carbon Black Cloud. This function allows users to easily uninstall the Carbon Black Cloud sensor from a specified computer. The function returns the uninstall code for the specified computer.

The script is written by Mohamed Hassan, and it is not responsible for any issues caused by the script. The script requires PowerShell 5.1 or later, and it requires the Carbon Black Cloud API credentials to be stored in the script's variables. The script is intended for use by administrators and security professionals who are familiar with PowerShell and the Carbon Black Cloud platform.
#>

param (
)
# Variables
$Global:OrgKey = "ORGGKEY"                                              # Add your org key here
$Global:APIID = "APIID"                                                 # Add your API ID here
$Global:APISecretKey = "APISECRETTOKEN"                                 # Add your API Secret token here
$Global:Hostname = "https://defense-xx.conferdeploy.net"                # Add your CBC URL here
$Global:Headers = @{"X-Auth-Token" = "$APISecretKey/$APIID" }           # APIrequest headers

#Functions
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
        $Range = '-1w',
        [string]$search,
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
        Clear-Host
        $Global:OrgKey = "7R2ARMW7"                                              # Add your org key here
        $Global:APIID = "J3CDSJL5HB"                                             # Add your API ID here
        $Global:APISecretKey = "9TNHDIQD1KDYG17F2SFUFQIT"                        # Add your API Secret token here
        $Global:Hostname = "https://defense-eu.conferdeploy.net"                 # Add your CBC URL here
        $Global:Headers = @{"X-Auth-Token" = "$APISecretKey/$APIID" }
        $Global:Uri = "$Hostname/api/alerts/v7/orgs/$OrgKey/alerts/_search"
    }
    
    process {
        $jsonBody = "{
        
    }"
        $psObjBody = $jsonBody |  ConvertFrom-Json
        if ($search) { $psObjBody | Add-Member -Name "query" -Value $search -MemberType NoteProperty }  
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
            $psObjBody | Add-Member -Name "rows" -Value $rows -MemberType NoteProperty -force
            $psObjBody | Add-Member -Name "start" -Value $start -MemberType NoteProperty -Force
        }
        $jsonBody = $psObjBody | ConvertTo-Json
        $Response = Invoke-WebRequest -Uri $Uri -Headers $Headers -Method Post -Body $jsonBody -ContentType "application/json"
        $Data = $Response.Content | Convertfrom-Json
    }
    
    end {
        $Data.results
    }
}
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
        Clear-Host
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
function Get-CBCPolicy {
    <#
    .SYNOPSIS
        Function to retrieve policies from Carbon Black Cloud using the CBC API.
    .DESCRIPTION
        This function will retrieve policies from Carbon Black Cloud and display them in a summary or detailed view.
    .NOTES
        Author: Mohamed Hassan
        Date: 2022-01-24
        Version: 1.0.0
    .PARAMETER All
        Switch to retrieve all policies in a summary view.
    .PARAMETER PolicyID
        Specify the Policy ID to retrieve a detailed view of the policy.
    .PARAMETER PolicyName
        Specify the Policy Name to retrieve a detailed view of the policy.
    .EXAMPLE
        PS C:\> Get-CBCPolicy -All
        Retrieves all policies in a summary view.
    .EXAMPLE
        PS C:\> Get-CBCPolicy -PolicyID 1234567890
        Retrieves a detailed view of the policy with the ID 1234567890.
    .EXAMPLE
        PS C:\> Get-CBCPolicy -PolicyName "My Policy"
        Retrieves a detailed view of the policy with the name "My Policy".
#>
    [CmdletBinding(DefaultParameterSetName = 'Summary')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Summary')]
        [switch]$All,
        [Parameter(Mandatory = $true, ParameterSetName = 'Detail')]
        [int]$PolicyID,
        [Parameter(Mandatory = $false, ParameterSetName = 'Detail')]
        [string]$PolicyName
    )
        
    begin {
        Clear-Host
        $Uri_Summary = "$Hostname/policyservice/v1/orgs/$OrgKey/policies/summary"
    }
        
    process {
        if ($PolicyID) {
            $Uri_Detail = "$Hostname/policyservice/v1/orgs/$OrgKey/policies/$PolicyID"
            try {
                $Response = Invoke-WebRequest -Uri $Uri_Detail -Headers $Headers -Method Get -ContentType "application/json"    
                $Data = $Response.Content | Convertfrom-Json
                $Data
            }
            catch {
                Write-Error "Policy ID not found"
                break
            }
                
        }
        if ($PolicyName) {
            try {
                $Response = Invoke-WebRequest -Uri $Uri_Summary -Headers $Headers -Method Get -ContentType "application/json"
                $Data = $Response.Content | Convertfrom-Json
                $PolicyID = ($Data.policies | Where-Object { $_.name -eq $PolicyName }).id
                $Uri_Detail = "$Hostname/policyservice/v1/orgs/$OrgKey/policies/$PolicyID"
                $Response = Invoke-WebRequest -Uri $Uri_Detail -Headers $Headers -Method Get -ContentType "application/json"
                $Data = $Response.Content | Convertfrom-Json
                $Data
            }
            catch {
                Write-Error "Policy Name not found"
                break
            }
    
        }  
        if ($All) {
            $Response = Invoke-WebRequest -Uri $Uri_Summary -Headers $Headers -Method Get -ContentType "application/json" 
            $Data = $Response.Content | Convertfrom-Json
            $Data.policies
        }
            
    }
        
    end {
            
    }
}
function Get-CBCUninstallCode {
    <#
    .Synopsis
        Retrieve the uninstall code for a specified computer from Carbon Black Cloud.
    
    .DESCRIPTION
        This PowerShell script interacts with the Carbon Black Cloud (CBC) API to retrieve the uninstall code for a specified computer. It prompts the user to enter the computer name and confirms the action before making the API request.
    
    .EXAMPLE
        .\Get-CBCUninstallCode.ps1
    
        This command will prompt the user to select an action and enter the computer name to retrieve the uninstall code from Carbon Black Cloud.
    
    .OUTPUTS
        [String]
        The script outputs the uninstall code for the specified computer.
    
    .NOTES
        Written by Mohamed Hassan
        I take no responsibility for any issues caused by this script.
    
    .FUNCTIONALITY
        - Set up global variables for Carbon Black Cloud credentials and API endpoint.
        - Display a menu for the user to choose the action (Get CBC Uninstall code or Exit).
        - Validate user input to ensure a valid choice is made.
        - Prompt the user to enter the computer name.
        - Confirm the entered computer name with the user.
        - Construct the body of the API request with the specified computer name.
        - Send the API request to retrieve the uninstall code and process the response.
        - Display the retrieved uninstall code.
    
    .LINK
        https://developer.carbonblack.com/reference/carbon-black-cloud/platform/latest/device-api/
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 0, HelpMessage = "Enter the computer name:")]
        $ComputerName
    )
        
    begin {
        Clear-Host
        $Global:Uri = "$Hostname/appservices/v6/orgs/$OrgKey/devices/_search"
    }
        
    process {
        $jsonBody = "{
            
        }"
        $psObjBody = $jsonBody |  ConvertFrom-Json
        $psObjBody | Add-Member -Name "deployment_type" -Value "ENDPOINT" -MemberType NoteProperty
        $psObjBody | Add-Member -Name "query" -Value $ComputerName -MemberType NoteProperty
        $jsonBody = $psObjBody | ConvertTo-Json
        # Query API
        $Response = Invoke-WebRequest -Uri $Uri -Headers $Headers -Method Post -Body $jsonBody -ContentType "application/json"
        $Data = $Response.Content | Convertfrom-Json
        ""
        Write-Output ( "
        Computer Name       : $($data.results.name)
        Uninstall Code      : $($data.results.uninstall_code)
        Username            : $($data.results.login_user_name)
        OS                  : $($data.results.os)
        OS Veresion         : $($data.results.os_version)
        AD Domain           : $($data.results.ad_domain)
        Asset Group         : $($data.results.asset_group.name)
        Device ID           : $($data.results.id)
        MAC Adress          : $($data.results.mac_address)
        Device Type         : $($data.results.sensor_kit_type)
        Out of Date         : $($data.results.sensor_out_of_date)
        Pending Update      : $($data.results.pending_update)
        Sensor Version      : $($data.results.sensor_version)
        Sensor States       : $($data.results.sensor_states)
        Status              : $($data.results.status)
        AV Version          : $($data.results.av_ave_version)
        AV Engine           : $($data.results.av_engine)
        AV Status           : $($data.results.av_status)
        Policy ID           : $($data.results.policy_id)
        Policy Name         : $($data.results.policy_name)
        Quarantined         : $($data.results.quarantined)
        Registered Time     : $($data.results.registered_time)
        Last Contact Time   : $($data.results.last_contact_time)
        Last Shutdown Time  : $($data.results.last_shutdown_time)
        Last External IP    : $($data.results.last_external_ip_address)
        Last Internal IP    : $($data.results.last_internal_ip_address)
        Organization ID     : $($data.results.organization_id)
        Organization Name   : $($data.results.organization_name)
        ")
    }
    end {
            
    }
}
function Show-ScriptHelp {
    [CmdletBinding()]
    param()
    Clear-Host
    Write-Host "This PowerShell script is a collection of functions that interact with the Carbon Black Cloud (CBC) API to retrieve and display information about alerts, devices, policies, and uninstall codes." -ForegroundColor Yellow
    Write-Host "This script contains the following functions:" -ForegroundColor Yellow
    
    Write-Host ""
    Write-Host "Get-CBCAlert" -ForegroundColor Green
    Write-Host "Retrieves alerts from Carbon Black Cloud based on a user-selected time range."
    Write-Host "Parameters:" -ForegroundColor Cyan
    Write-Host "  -Range: The time range for the alerts. Valid values are '-1d', '-3d', '-1w', '-2w', '-1m', and '-3m'. Default is '-1d'."
    Write-Host "  -Search: A search query to filter the alerts."
    Write-Host "  -Rows: The number of rows to display. Default is 10000."
    Write-Host "  -Start: The starting row number. Default is 1."
    Write-Host "  -Order: The sort order. Valid values are 'ASC' and 'DESC'. Default is 'ASC'."
    Write-Host "  -MinimumSeverity: The minimum severity of the alerts to retrieve."
    Write-Host "  -OS: The operating system of the devices to retrieve alerts for. Valid values are 'Windows', 'Mac', and 'Linux'."
    Write-Host "  -All: A switch parameter to retrieve all alerts."
    Write-Host "Examples:" -ForegroundColor Magenta
    Write-Host "  Get-CBCAlert -minimumseverity 5 -range -2w | out-gridview" -ForegroundColor Cyan
    Write-Host "    Sample output:" -ForegroundColor DarkYellow
    Write-Host "    ID        DetectionTimestamp           Severity DeviceName                                 Reason" -ForegroundColor DarkYellow
    Write-Host "    --        ------------------           -------- -----------                                 ------" -ForegroundColor DarkYellow
    Write-Host "    123456789 2022-01-01T12:00:00Z               5 WIN10-WORKSTATION                       Malware detected" -ForegroundColor DarkYellow
    Write-Host "    987654321 2022-01-02T13:00:00Z               7 WIN10-SERVER                           Unauthorized software installed" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  Get-CBCAlert -search 'malware' | out-gridview" -ForegroundColor Cyan
    Write-Host "    Sample output:" -ForegroundColor DarkYellow
    Write-Host "    ID        DetectionTimestamp           Severity DeviceName                                 Reason" -ForegroundColor DarkYellow
    Write-Host "    --        ------------------           -------- -----------                                 ------" -ForegroundColor DarkYellow
    Write-Host "    123456789 2022-01-01T12:00:00Z               5 WIN10-WORKSTATION                       Malware detected" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  Get-CBCAlert -os 'Windows' -minimumseverity 7 | out-gridview" -ForegroundColor Cyan
    Write-Host "    Sample output:" -ForegroundColor DarkYellow
    Write-Host "    ID        DetectionTimestamp           Severity DeviceName                                 Reason" -ForegroundColor DarkYellow
    Write-Host "    --        ------------------           -------- -----------                                 ------" -ForegroundColor DarkYellow
    Write-Host "    987654321 2022-01-02T13:00:00Z               7 WIN10-SERVER                           Unauthorized software installed" -ForegroundColor DarkYellow

    Write-Host ""
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "Get-CBCDevice" -ForegroundColor Green
    Write-Host "Retrieves device information from Carbon Black Cloud using the Alert API."
    Write-Host "Parameters:" -ForegroundColor Cyan
    Write-Host "  -Search: A search query to filter the devices."
    Write-Host "  -Rows: The number of rows to display."
    Write-Host "  -Start: The starting row number."
    Write-Host "  -Order: The sort order. Valid values are 'ASC' and 'DESC'. Default is 'ASC'."
    Write-Host "  -DeploymentType: The deployment type of the devices to retrieve. Valid values are 'ENDPOINT', 'WORKLOAD', 'AZURE', 'GCP', 'AWS', and 'VDI'."
    Write-Host "  -OS: The operating system of the devices to retrieve. Valid values are 'WINDOWS', 'LINUX', and 'MAC'."
    Write-Host "  -PolicyID: The policy ID of the devices to retrieve."
    Write-Host "  -PolicyName: The policy name of the devices to retrieve."
    Write-Host "  -SensorVersion: The sensor version of the devices to retrieve."
    Write-Host "  -Quarantined: A flag to retrieve quarantined devices."
    Write-Host "  -All: A switch parameter to retrieve all devices."
    Write-Host "Examples:" -ForegroundColor Magenta
    Write-Host "  Get-CBCDevice -DeploymentType ENDPOINT | ft -AutoSize" -ForegroundColor Cyan
    Write-Host "    Sample output:" -ForegroundColor DarkYellow
    Write-Host "    Name                  ID          OS       PolicyName" -ForegroundColor DarkYellow
    Write-Host "    ----                  --          ----       ----------" -ForegroundColor DarkYellow
    Write-Host "    WIN10-WORKSTATION     1234567890  WINDOWS  Standard Policy" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  Get-CBCDevice -search '*server*' -os 'Linux' | ft -AutoSize" -ForegroundColor Cyan
    Write-Host "    Sample output:" -ForegroundColor DarkYellow
    Write-Host "    Name                  ID          OS       PolicyName" -ForegroundColor DarkYellow
    Write-Host "    ----                  --          ----       ----------" -ForegroundColor DarkYellow
    Write-Host "    UBUNTU-SERVER-01      9876543210  LINUX   Server Policy" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  Get-CBCDevice -policyID 1234567890 | ft -AutoSize" -ForegroundColor Cyan
    Write-Host "    Sample output:" -ForegroundColor DarkYellow
    Write-Host "    Name                  ID          OS       PolicyName" -ForegroundColor DarkYellow
    Write-Host "    ----                  --          ----       ----------" -ForegroundColor DarkYellow
    Write-Host "    WIN10-WORKSTATION     1234567890  WINDOWS  Standard Policy" -ForegroundColor DarkYellow

    Write-Host ""
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "Get-CBCPolicy" -ForegroundColor Green
    Write-Host "Retrieves policies from Carbon Black Cloud."
    Write-Host "Parameters:" -ForegroundColor Cyan
    Write-Host "  -All: A switch parameter to retrieve all policies in a summary view."
    Write-Host "  -PolicyID: The policy ID to retrieve a detailed view of the policy."
    Write-Host "  -PolicyName: The policy name to retrieve a detailed view of the policy."
    Write-Host "Examples:" -ForegroundColor Magenta
    Write-Host "  Get-CBCPolicy -All | ft -AutoSize" -ForegroundColor Cyan
    Write-Host "    Sample output:" -ForegroundColor DarkYellow
    Write-Host "    ID          Name            Description" -ForegroundColor DarkYellow
    Write-Host "    --          ----            -----------" -ForegroundColor DarkYellow
    Write-Host "    1234567890  Standard Policy Default policy for endpoints" -ForegroundColor DarkYellow
    Write-Host "    9876543210  Server Policy   Policy for Linux servers" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  Get-CBCPolicy -PolicyID 1234567890" -ForegroundColor Cyan
    Write-Host "    Sample output:" -ForegroundColor DarkYellow
    Write-Host "    ID          Name            Description" -ForegroundColor DarkYellow
    Write-Host "    --          ----            -----------" -ForegroundColor DarkYellow
    Write-Host "    1234567890  Standard Policy Default policy for endpoints" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  Get-CBCPolicy -PolicyName 'Standard Policy'" -ForegroundColor Cyan
    Write-Host "    Sample output:" -ForegroundColor DarkYellow
    Write-Host "    ID          Name            Description" -ForegroundColor DarkYellow
    Write-Host "    --          ----            -----------" -ForegroundColor DarkYellow
    Write-Host "    1234567890  Standard Policy Default policy for endpoints" -ForegroundColor DarkYellow

    Write-Host ""
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "Get-CBCUninstallCode" -ForegroundColor Green
    Write-Host "Retrieves the uninstall code for a specified computer from Carbon Black Cloud."
    Write-Host "Parameters:" -ForegroundColor Cyan
    Write-Host "  -ComputerName: The name of the computer to retrieve the uninstall code for."
    Write-Host "Examples:" -ForegroundColor Magenta
    Write-Host "  Get-CBCUninstallCode -ComputerName 'MyComputer'" -ForegroundColor Cyan
    Write-Host "    Sample output:" -ForegroundColor DarkYellow
    Write-Host "    Computer Name       : MyComputer" -ForegroundColor DarkYellow
    Write-Host "    Uninstall Code      : ABCDEFGHIJKLMNOPQRSTUVWXYZ" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  Get-CBCUninstallCode -ComputerName 'Server01' | select UninstallCode" -ForegroundColor Cyan
    Write-Host "    Sample output:" -ForegroundColor DarkYellow
    Write-Host "    UninstallCode" -ForegroundColor DarkYellow
    Write-Host "    --------------" -ForegroundColor DarkYellow
    Write-Host "    ABCDEFGHIJKLMNOPQRSTUVWXYZ" -ForegroundColor DarkYellow

    Write-Host ""
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "https://developer.carbonblack.com/reference/carbon-back-cloud/platform/latest/alerts-api/" -ForegroundColor DarkCyan
    Write-Host "https://developer.carbonblack.com/reference/carbon-black-cloud/platform/latest/device-api/" -ForegroundColor DarkCyan
}


Show-ScriptHelp