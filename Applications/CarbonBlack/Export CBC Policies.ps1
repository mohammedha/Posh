
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