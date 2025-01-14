<#
.SYNOPSIS
    This script will export all Carbon Black Cloud policies to json files, each with the policy name and ID in the filename.
.DESCRIPTION
    The script will query the Carbon Black Cloud API for all policies, then call the Get-CBCPolicy cmdlet with the -Backup parameter to
    save the policy details to a json file. The filename will be in the format: <PolicyName>_<PolicyID>.json.
.NOTES
    The script requires the Carbon Black Cloud API key and secret key to be set as environment variables CBC_API_KEY and CBC_API_SECRET_KEY.
    The script will backup all policies, regardless of type, to individual json files.
#>

# Query the Carbon Black Cloud API for all policies
$Policies = get-cbcpolicy -all # https://powershellprodigy.wordpress.com/2025/01/08/streamlining-carbon-black-cloud-policy-management-using-powershell/

# Loop through each policy
foreach ($policy in $policies) {
    $id = $policy.id
    $PolicyName = $policy.name
    # Write a message to indicate which policy is being backed up
    Write-Information "Backing policy $PolicyName with ID: $id" -InformationAction Continue -Verbose  
    # Back up the policy using Get-CBCPolicy with the -Backup parameter
    Get-CBCPolicy -PolicyID $id -backup
    # Rename the backup file to include the policy name and ID
    Rename-Item ".\$($id).json" "$($PolicyName)_$($id).json"
}


