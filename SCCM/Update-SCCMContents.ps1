function Connect-SCCM {
    <#
.SYNOPSIS
Connects to an SCCM (System Center Configuration Manager) environment.

.DESCRIPTION
This function connects to a specified SCCM site using the provided site code and provider machine FQDN. It ensures that the ConfigurationManager module is imported and the SCCM site drive is available before establishing the connection.

.PARAMETER SiteCode
The site code of the SCCM site you want to connect to. The default value is "ZBG".

.PARAMETER ProviderMachineName
The fully qualified domain name (FQDN) of the SCCM provider machine. The default value is "ZH-BGL-SCCM03.zaha-hadid.com".

.PARAMETER ShowVerbose
Switch parameter that enables verbose output during the module import and site drive connection process.

.PARAMETER ShowErrors
Switch parameter that sets the error action to "Stop" when an error occurs during the module import or site drive connection.

.EXAMPLE
Connect-SCCM -SiteCode ZBG -ProviderMachineName ZH-BGL-SCCM03.zaha-hadid.com

This example connects to the SCCM site with the code "ZBG" using the provider machine "ZH-BGL-SCCM03.zaha-hadid.com".

.EXAMPLE
Connect-SCCM -SiteCode ZBG -ProviderMachineName ZH-BGL-SCCM03.zaha-hadid.com -ShowVerbose

This example connects to the SCCM site with the code "ZBG" using the provider machine "ZH-BGL-SCCM03.zaha-hadid.com" and displays verbose output.

.EXAMPLE
Connect-SCCM -SiteCode ZBG -ProviderMachineName ZH-BGL-SCCM03.zaha-hadid.com -ShowErrors

This example connects to the SCCM site with the code "ZBG" using the provider machine "ZH-BGL-SCCM03.zaha-hadid.com" and stops on any errors.

.NOTES
Author: Mohamed Hassan
Date: 2025-02-04
Version: 1.0

.LINK
https://github.com/mohammedha/Posh
#>
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = 'Enter SCCM site code')]
        $SiteCode,
        [Parameter(HelpMessage = 'Enter SCCM provider machine FQDN name')]
        $ProviderMachineName,
        [switch]$ShowVerbose,
        [switch]$ShowErrors
    )
    
    begin {
        # Customizations
        $initParams = @{}
        if ($ShowVerbose) {
            $initParams.Add("Verbose", $true)
        }
        if ($ShowErrors) {
            $initParams.Add("ErrorAction", "Stop")
        }
    }
    
    process {
        # Import the ConfigurationManager.psd1 module 
        if ($null -eq (Get-Module ConfigurationManager)) {
            Write-Output "Importing ConfigurationManager module..."
            Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
        }
        # Connect to the site's drive if it is not already present
        if ($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
            Write-Output "Connecting to SCCM site [$SiteCode] on [$ProviderMachineName]..."
            New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
        }
    }
    
    end {
        # Set the current location to be the site code.
        Set-Location "$($SiteCode):\" @initParams
    }
}
function Update-CMApplication {
    <#
.SYNOPSIS
    Updates distribution points for applications in Configuration Manager (SCCM).

.DESCRIPTION
    This script updates distribution points for applications based on a filter or all applications if no filter is provided. It checks if the application is retired and skips updating retired applications.

.PARAMETER Filter
    Optional parameter to filter software packages by name.
    If specified, only applications matching this name will be updated.
    Default: None (all applications will be updated).

.PARAMETER ShowVerbose
    Switch parameter to enable verbose output during the update process.
    When used, detailed information about each application and its deployment types will be displayed.

.EXAMPLE
    Update-CMApplication -Filter "Office*" -ShowVerbose
    Updates distribution points for all applications that have names starting with "Office" and shows verbose output.

.EXAMPLE
    Update-CMApplication
    Updates distribution points for all applications without any filtering or verbose output.
    
.NOTES
    - This function requires administrative privileges in Configuration Manager.
    - Ensure you are connected to the correct site server before running this script.

.LINK
    https://github.com/mohammedha/Posh

#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            Position = 0,
            HelpMessage = "Filter software packages by name")]
        [string]$Filter,
        [switch]$ShowVerbose
    )
    begin {
        
    }
    process {
        if ($Filter) {
            $Applications = Get-CMDistributionStatus | Where-Object { ($_.ObjectTypeID -eq 31) -and ($_.SoftwareName -match $Filter) }
            Write-Host "[$((Get-Date).TimeofDay)] Found [$($Applications.Count)] software packages" -ForegroundColor Yellow
            Read-host "Press any key to continue... [Ctrl + C to cancel]"
        }
        else {
            $Applications = Get-CMDistributionStatus | Where-Object { ($_.ObjectTypeID -eq 31) }
            Write-Warning "No filter specified, all software packages will be updated"
            Write-Host "[$((Get-Date).TimeofDay)] Found [$($Applications.Count)] software packages" -ForegroundColor Yellow
            Read-host "Press any key to continue... [Ctrl + C to cancel]"
        }
        $Applications | ForEach-Object {
            if ($((Get-CMDeploymentType -ApplicationName $_.SoftwareName).IsExpired -eq $true)) {
                Write-Host "[$((Get-Date).TimeofDay)] - Application: $($_.SoftwareName) - ID: $($_.PackageID) - Status: Retired - Action: Skip" -ForegroundColor Yellow
            }
            else {
                Write-Host "[$((Get-Date).TimeofDay)] - Application: $($_.SoftwareName) - ID: $($_.PackageID) - Status: Active - Action: Updating content..." -ForegroundColor Green
                if ($ShowVerbose) {
                    Update-CMDistributionPoint -ApplicationName $_.SoftwareName -DeploymentTypeName $((Get-CMDeploymentType -ApplicationName $_.SoftwareName).LocalizedDisplayName) -Verbose
                }
                else {
                    Update-CMDistributionPoint -ApplicationName $_.SoftwareName -DeploymentTypeName $((Get-CMDeploymentType -ApplicationName $_.SoftwareName).LocalizedDisplayName)
                }
            }
        }
    }
    end {
        
    }
}
function Update-CMPackage {
    <#
    .SYNOPSIS
            Updates content for software packages in System Center Configuration Manager (SCCM).
    .DESCRIPTION
    This script updates the distribution points for software packages in SCCM. It can filter packages by name and provides options to show verbose output.
    .PARAMETER Filter
        Optional parameter to filter packages by their names using a regular expression pattern.

        Example:
        Update-CMPackage -Filter "Microsoft Office.*"
    .PARAMETER ShowVerbose
        Switch parameter to enable verbose logging during the update process. This will provide detailed output about each package being updated.
    .EXAMPLE
        Update-CMPackage
        Updates all software packages without filtering and without verbose output.
    .EXAMPLE
        Update-CMPackage -Filter "Microsoft Office.*" -ShowVerbose
        Updates software packages with names matching "Microsoft Office.*" and displays verbose output for each update.
    .NOTES
        - Requires administrative privileges on the SCCM server.
        - Ensure that the SCCM module is imported before running this function (e.g., Import-Module ConfigurationManager).
    .NOTES
        This script uses the Get-CMDistributionStatus, Get-CMProgram, and Update-CMDistributionPoint cmdlets from the SCCM PowerShell module to perform its operations.
    .NOTES
        Author: Mohamed Hassan
        Date: 2025-02-04
        Version: 1.0
    .LINK
        https://github.com/mohammedha/Posh
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            Position = 0,
            HelpMessage = "Filter software packages by name")]
        [string]$Filter,
        [switch]$ShowVerbose
    )
    begin {
        
    }
    process {
        if ($Filter) {
            $Packages = Get-CMDistributionStatus | Where-Object { ($_.ObjectTypeID -eq 2) -and ($_.SoftwareName -match $Filter) }
            Write-Host "[$((Get-Date).TimeofDay)] Found [$($Packages.Count)] software packages" -ForegroundColor Yellow
            Read-host "Press any key to continue... [Ctrl + C to cancel]"
        }
        else {
            $Packages = Get-CMDistributionStatus | Where-Object { ($_.ObjectTypeID -eq 2) }
            Write-Warning "No filter specified, all software packages will be updated"
            Write-Host "[$((Get-Date).TimeofDay)] Found [$($Packages.Count)] software packages" -ForegroundColor Yellow
            Read-host "Press any key to continue... [Ctrl + C to cancel]"
        }
        $Packages | ForEach-Object { 
            write-host "[$((Get-Date).TimeofDay)] - Package: $($_.SoftwareName) - ID: $($_.ObjectID) - Program: $(if (-not $((Get-CMProgram -PackageID $($_.ObjectID)).ProgramName)) {write-output "No Program"}) - Status: Active - Action: Updating content..." -ForegroundColor Yellow
            if ($ShowVerbose) {
                Update-CMDistributionPoint -PackageId $($_.PackageId) -Verbose
            }
            else {
                Update-CMDistributionPoint -PackageId $($_.PackageId)
            }
        }
    }
    end {
        
    }
}

