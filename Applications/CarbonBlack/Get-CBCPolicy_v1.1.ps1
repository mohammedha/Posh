function Get-CBCPolicy {
    <#
    .SYNOPSIS
        Retrieve policies from Carbon Black Cloud using the CBC API.
    .DESCRIPTION
        This function retrieves policies from Carbon Black Cloud and displays them in either a summary or detailed view. It supports filtering by policy ID or name and includes an option to backup policies.
    .NOTES
        Author: Mohamed Hassan
        Date: 2025-01-08
        Version: 1.1.0
    .PARAMETER All
        Switch to retrieve all policies in a summary view.
    .PARAMETER PolicyID
        Specify the Policy ID to retrieve a detailed view of the policy.
    .PARAMETER PolicyName
        Specify the Policy Name to retrieve a detailed view of the policy.
    .PARAMETER Backup
        Switch to backup the policies being retrieved.
    .EXAMPLE
        PS C:\> Get-CBCPolicy -All
        Retrieves all policies in a summary view.
    .EXAMPLE
        PS C:\> Get-CBCPolicy -PolicyID 1234567890
        Retrieves a detailed view of the policy with the ID 1234567890.
    .EXAMPLE
        PS C:\> Get-CBCPolicy -PolicyName "My Policy"
        Retrieves a detailed view of the policy with the name "My Policy".
    .EXAMPLE
        PS C:\> Get-CBCPolicy -PolicyID 1234567890 -Backup
        Retrieves and backs up the  policy to JSON file
#>
    [CmdletBinding(DefaultParameterSetName = 'Summary')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Summary')]
        [switch]$All,
        [Parameter(Mandatory = $true, ParameterSetName = 'Detail')]
        [int]$PolicyID,
        [Parameter(Mandatory = $false, ParameterSetName = 'Detail')]
        [string]$PolicyName,
        [Parameter(Mandatory = $false, ParameterSetName = 'Detail')]
        [switch]$backup
    )
        
    begin {
        #Clear-Host
        $Uri_Summary = "$Hostname/policyservice/v1/orgs/$OrgKey/policies/summary"
    }
        
    process {
        if ($backup) {
            $Uri_Detail = "$Hostname/policyservice/v1/orgs/$OrgKey/policies/$PolicyID"            
            Write-Information "[i] [$(Get-Date -Format "[yyyy-MM-dd][HH:mm:ss]")] Retrieving policy $PolicyID from Carbon Black Cloud..." -InformationAction Continue 
            $Response = Invoke-WebRequest -Uri $Uri_Summary -Headers $Headers -Method Get -ContentType "application/json" 
            $Data = $Response.Content
            Write-Information "[i] [$(Get-Date -Format "[yyyy-MM-dd][HH:mm:ss]")] Backing up policy $PolicyID to .\$($PolicyID).json" -InformationAction Continue
            $Data | Out-File ".\$($PolicyID).json"
        }
        if ($PolicyID) {
            $Uri_Detail = "$Hostname/policyservice/v1/orgs/$OrgKey/policies/$PolicyID"
            try {
                $Response = Invoke-WebRequest -Uri $Uri_Detail -Headers $Headers -Method Get -ContentType "application/json"
                Write-Information "[i] [$(Get-Date -Format "[yyyy-MM-dd][HH:mm:ss]")] Retrieving policy $PolicyID from Carbon Black Cloud..." -InformationAction Continue
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
                Write-Information "[i] [$(Get-Date -Format "[yyyy-MM-dd][HH:mm:ss]")] Retrieving policy $PolicyID from Carbon Black Cloud..." -InformationAction Continue
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
            Write-Information "[i] [$(Get-Date -Format "[yyyy-MM-dd][HH:mm:ss]")] Retrieving all policies from Carbon Black Cloud..." -InformationAction Continue
            $Response = Invoke-WebRequest -Uri $Uri_Summary -Headers $Headers -Method Get -ContentType "application/json" 
            $Data = $Response.Content | Convertfrom-Json
            $Data.policies
        }

            
    }
        
    end {
            
    }
}