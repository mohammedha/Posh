
function Get-UninstallKey {
    <#
    .SYNOPSIS
        Retrieves uninstall keys for a specified application from the Windows registry.
    .DESCRIPTION
        This function searches the specified registry paths for uninstall entries that match the provided application name.
        It returns detailed information about each matching key, including the registry path, display name, version,
        publisher, uninstall string, quiet uninstall string, bundle cache path, and bundle provider key.
    .PARAMETER AppName
        The name of the application to search for in the uninstall registry keys.
    .EXAMPLE
        $uninstallKeys = Get-UninstallKey -AppName "Google Chrome" -version "120"
        $uninstallKeys | Format-Table
    .NOTES
        Author: Your Name
        Date:   Current Date
        Version: 1.0
        This script queries the following registry paths:
        - HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall
        - HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
        The function returns a list of uninstall keys that match the provided application name, including:
        - PSPath: The cleaned registry path without the prefix.
        - DisplayName: The display name of the application.
        - DisplayVersion: The version of the application.
        - Publisher: The publisher of the application.
        - UninstallString: The standard uninstall command.
        - QuietUninstallString: The quiet uninstall command, if available.
        - BundleCachePath: The bundle cache path, if available.
        - BundleProviderKey: The bundle provider key, if available.
        If no matching uninstall keys are found, the function outputs a message indicating that no keys were found.
    .LINK
        https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-childitem?view=powershell-7.2
        https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-itemproperty?view=powershell-7.2
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$AppName,
        [version]$Version
    )
    # Define the registry paths to search for uninstall entries
    $registryPaths = @(
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    )
    
    $uninstallKeysList = @()
    $bundleCachePaths = @()  # New variable to store bundle cache paths

    foreach ($path in $registryPaths) {
        try {
            # Retrieve all uninstall keys from the current registry path
            $uninstallKeys = Get-ChildItem -Path $path -ErrorAction Stop |
            Get-ItemProperty -ErrorAction SilentlyContinue |
            Where-Object { ($_.PSObject.Properties.Value -match $AppName) -and ($_.PSObject.Properties.Value -match $Version) }
            if ($uninstallKeys) {
                foreach ($key in $uninstallKeys) {
                    # Clean the PSPath by removing the "Microsoft.PowerShell.Core\Registry::" prefix
                    $cleanedPath = $key.PSPath -split "::", 2 | Select-Object -Last 1
                    Write-Verbose "Parent Key: $cleanedPath"
                    # Create a custom object with the desired properties and add it to the list
                    $uninstallKeyInfo = [PSCustomObject]@{
                        PSPath               = $cleanedPath
                        DisplayName          = $key.DisplayName
                        DisplayVersion       = $key.DisplayVersion
                        Publisher            = $key.Publisher
                        UninstallString      = $key.UninstallString
                        QuietUninstallString = $key.QuietUninstallString
                        BundleCachePath      = $key.BundleCachePath
                        BundleProviderKey    = $key.BundleProviderKey
                    }
                    $uninstallKeysList += $uninstallKeyInfo

                    # Save the bundle cache path if it exists
                    if ($key.BundleCachePath) {
                        $bundleCachePaths += $key.BundleCachePath
                    }
                }
            }
        }
        catch {
            # Handle any errors that occur while accessing the registry path
            Write-Error "Failed to access registry path $path. $_"
        }
    }

    # Return the list of uninstall keys and bundle cache paths if found, otherwise return empty arrays
    if ($uninstallKeysList.Count -eq 0) {
        Write-Output "No uninstall key found for application '$AppName'."
        return @(), @()
    }
    else {
        return $uninstallKeysList, $bundleCachePaths
    }
}
