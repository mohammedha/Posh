function New-CBCDeviceAction {
    <#
    .SYNOPSIS
    Create a new device action in Carbon Black Cloud.
    .DESCRIPTION
    This function creates a new device action in Carbon Black Cloud.
    .PARAMETER DeviceID
    The ID of the device to create the action for. This parameter is required.
    .PARAMETER Action
    The action to take on the device. Valid values are "QUARANTINE", "BYPASS", "BACKGROUND_SCAN", "UPDATE_POLICY", "UPDATE_SENSOR_VERSION", "UNINSTALL_SENSOR", "DELETE_SENSOR" This parameter is required.
    .PARAMETER Toggle
    The toggle to set for the device. Valid values are 'ON', 'OFF'. This parameter is optional.
    .PARAMETER SensorType
    The type of sensor to set for the device. Valid values are 'XP', 'WINDOWS', 'MAC', 'AV_SIG', 'OTHER', 'RHEL', 'UBUNTU', 'SUSE', 'AMAZON_LINUX', 'MAC_OSX'. This parameter is optional.
    .PARAMETER SensorVersion
    The version of the sensor to set for the device. This parameter is optional.
    .PARAMETER PolicyID
    The ID of the policy to set for the device. This parameter is optional. Either policy_id or auto_assign is required if action_type is set to UPDATE_POLICY
    .EXAMPLE
    New-CBCDeviceAction -DeviceID 123456789 -Action QUARANTINE -Toggle ON
    This will create a new device action to quarantine the device with the ID 123456789.
    .EXAMPLE
    New-CBCDeviceAction -DeviceID 123456789 -Action BYPASS -Toggle OFF
    This will create a new device action to switch bypass OFF for the device with the ID 123456789.
    .EXAMPLE
    New-CBCDeviceAction -DeviceID 123456789 -Action BACKGROUND_SCAN -Toggle ON
    This will create a new device action to run background scan ON for the device with the ID 123456789.
    .EXAMPLE
    New-CBCDeviceAction -DeviceID 123456789 -Action SENSOR_UPDATE -SensorType WINDOWS -SensorVersion 1.2.3.4
    This will create a new device action to update the sensor on the device with the ID 123456789 to version 1.2.3.4 on Windows.
    .EXAMPLE
    New-CBCDeviceAction -DeviceID 123456789 -Action POLICY_UPDATE -PolicyID 123456789
    This will create a new device action to update the policy on the device with the ID 123456789 to the policy with the ID 123456789.
    .LINK
    https://developer.carbonblack.com/reference/carbon-black-cloud/platform/latest/devices-api/
    #>
    [CmdletBinding(DefaultParameterSetName = "DEVICEID")]
    param (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "SEARCH")]
        [string]$Search,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "DEVICEID")]
        [int[]]$DeviceID,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "PolicyID")]
        [int[]]$PolicyID,

        [ValidateNotNullOrEmpty()]

        [validateset("QUARANTINE", "BYPASS", "BACKGROUND_SCAN", "UPDATE_POLICY", "UPDATE_SENSOR_VERSION", "UNINSTALL_SENSOR", "DELETE_SENSOR")]
        [string]$Action,
        
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "DEVICEID")]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "SEARCH")]
        [validateset("ON", "OFF")]        
        [string]$Toggle,

        [Parameter(Mandatory = $true, ParameterSetName = "SENSOR")]
        [validateset("XP", "WINDOWS", "MAC", "AV_SIG", "OTHER", "RHEL", "UBUNTU", "SUSE", "AMAZON_LINUX", "MAC_OSX")]
        [string]$SensorType = "WINDOWS",

        [ValidateNotNullOrEmpty()]        
        [Parameter(Mandatory = $true, ParameterSetName = "SENSOR")]
        [int]$SensorVersion,



        [Parameter(Mandatory = $true, ParameterSetName = "PolicyID")]
        [switch]$AutoAssignPolicy

    )
        
    begin {
        #Clear-Host
        $Global:Uri = "$Hostname/appservices/v6/orgs/$OrgKey/device_actions"
    }
        
    process {
        # Create JSON Body
        $jsonBody = "{
        
        }"
        # Create PSObject Body
        $psObjBody = $jsonBody |  ConvertFrom-Json
        # build JSON Node for "DEVICEID" parameterset
        if ($Action) { $psObjBody | Add-Member -Name "action_type" -Value $Action.ToUpper() -MemberType NoteProperty }
        if ($DeviceID) { $psObjBody | Add-Member -Name "device_id" -Value @($DeviceID) -MemberType NoteProperty }
        if ($Search) {
            $psObjBody | Add-Member -Name "search" -Value ([PSCustomObject]@{}) -MemberType NoteProperty
            $psObjBody.search | Add-Member -Name "criteria" -Value ([PSCustomObject]@{}) -MemberType NoteProperty
            $psObjBody.search | Add-Member -Name "exclusions" -Value ([PSCustomObject]@{}) -MemberType NoteProperty
            $psObjBody.search | Add-Member -Name "query" -Value $Search -MemberType NoteProperty
        }
        # Build JSON 'OPTIONS' Node
        $psObjBody | Add-Member -Name "options" -Value ([PSCustomObject]@{}) -MemberType NoteProperty
        if ($Toggle) { 
            $psObjBody.options | Add-Member -Name "toggle" -Value $Toggle.ToUpper() -MemberType NoteProperty
        }
        # build JSON Node for "SENSOR" parameterset
        if ($SensorType) {
            $psObjBody.options | Add-Member -Name "sensor_version" -Value ([PSCustomObject]@{}) -MemberType NoteProperty
            $psObjBody.options.sensor_version | Add-Member -Name $SensorType.ToUpper() -Value $SensorVersion -MemberType NoteProperty
        }
        # build JSON Node for "POLICYID" parameterset
        if ($PolicyID) {
            $psObjBody.options | Add-Member -Name "policy_id" -Value $PolicyID -MemberType NoteProperty
        }
        # Convert PSObject to JSON
        $jsonBody = $psObjBody | ConvertTo-Json
        $Response = Invoke-WebRequest -Uri $Uri -Method Post -Headers $Headers -Body $jsonBody -ContentType "application/json"
        switch ($Response.StatusCode) {
            200 {
                Write-Output "Request successful."
                $Data = $Response.Content | ConvertFrom-Json
            }
            204 {
                Write-Output "Device action created successfully."
                $Data = $Response.Content | ConvertFrom-Json
            }
            400 {
                Write-Error -Message "Invalid request. Please check the parameters and try again."
            }
            500 {
                Write-Error -Message "Internal server error. Please try again later or contact support."
            }
            default {
                Write-Error -Message "Unexpected error occurred. Status code: $($Response.StatusCode)"
            }
        }
    }
    end {
        $Data.results
    }
}
