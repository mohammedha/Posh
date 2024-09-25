
function Get-CBCPolicy {
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
        $OrgKey = "OrgKey"                                              # Add your org key here
        $APIID = "APIID"                                             # Add your API ID here
        $APISecretKey = "APISecretKey"                        # Add your API Secret token here
        $Hostname = "https://defense-eu.conferdeploy.net"                 # Add your CBC URL here
        $Headers = @{"X-Auth-Token" = "$APISecretKey/$APIID" }
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