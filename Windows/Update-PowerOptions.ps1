<#
.SYNOPSIS
This script allows the user to enable or disable specific registry keys related to power options on the local computer.

.DESCRIPTION
The script presents a menu with options to enable or disable specific registry keys related to power options. The keys that can be modified are:
- Hide Shut Down
- Hide Restart
- Hide Sleep
- Hide Power Button

The script prompts the user to choose an option and then prompts for whether the user wants to enable or disable the selected option. The script uses the Set-ItemProperty cmdlet to modify the corresponding registry key based on the user's input.

.PARAMETER RegPath_Shutdown
Specifies the registry path for the "Hide Shut Down" key. Defaults to "HKCU:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideShutDown".

.PARAMETER RegPath_Restart
Specifies the registry path for the "Hide Restart" key. Defaults to "HKCU:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideRestart".

.PARAMETER RegPath_Sleep
Specifies the registry path for the "Hide Sleep" key. Defaults to "HKCU:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideSleep".

.PARAMETER RegPath_StartMenu
Specifies the registry path for the "Hide Power Button" key. Defaults to "HKCU:\SOFTWARE\Microsoft\PolicyManager\default\Start\HidePowerButton".

.PARAMETER RegValueName
Specifies the name of the registry value to be modified. Defaults to "value".

.EXAMPLE
Update-PowerOptions

Runs the script, which presents a menu of power options for the user to enable or disable.

.EXAMPLE
Update-RegistryPowerOptions -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideShutDown" -value 1

Runs the script, modifying the "Hide Shut Down" key located in the HKEY_LOCAL_MACHINE registry hive instead of the default HKEY_CURRENT_USER hive.

.NOTES
This script requires administrative privileges to modify registry keys.
#>

$RegPath_Shutdown = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideShutDown"
$RegPath_Restart = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideRestart"
$RegPath_Sleep = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideSleep"
$RegPath_StartMenu = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HidePowerButton"
$RegValueName = "value"

# Define a function to update a registry value
function Update-RegistryPowerOptions {
    param (
        [string]$path,
        [int]$value
    )
    Set-ItemProperty -Path $path -Name $RegValueName -Value $value
}

# Show a menu for the user to choose which registry values to update
while ($true) {
    Write-Host "Which setting would you like to update?"
    Write-Host "1. Hide Shut Down"
    Write-Host "2. Hide Restart"
    Write-Host "3. Hide Sleep"
    Write-Host "4. Hide Power Button"
    Write-Host "0. Exit"
    $choice = Read-Host "Enter your choice".Trim()

    switch ([int]$choice) {
        "1" {
            $value = Read-Host "Do you want to enable or disable the 'Hide Shut Down' setting? (E/D)"
            if ($value -eq "E") {
                Update-RegistryPowerOptions -path $RegPath_Shutdown -value 1
            }
            elseif ($value -eq "D") {
                Update-RegistryPowerOptions -path $RegPath_Shutdown -value 0
            }
        }
        "2" {
            $value = Read-Host "Do you want to enable or disable the 'Hide Restart' setting? (E/D)"
            if ($value -eq "E") {
                Update-RegistryPowerOptions -path $RegPath_Restart -value 1
            }
            elseif ($value -eq "D") {
                Update-RegistryPowerOptions -path $RegPath_Restart -value 0
            }
        }
        "3" {
            $value = Read-Host "Do you want to enable or disable the 'Hide Sleep' setting? (E/D)"
            if ($value -eq "E") {
                Update-RegistryPowerOptions -path $RegPath_Sleep -value 1
            }
            elseif ($value -eq "D") {
                Update-RegistryPowerOptions -path $RegPath_Sleep -value 0
            }
        }
        "4" {
            $value = Read-Host "Do you want to enable or disable the 'Hide Power Button' setting? (E/D)"
            if ($value -eq "E") {
                Update-RegistryPowerOptions -path $RegPath_StartMenu -value 1
            }
            elseif ($value -eq "D") {
                Update-RegistryPowerOptions -path $RegPath_StartMenu -value 0
            }
        }
        "0" {
            return
        }
        default {
            Write-Host "Invalid choice"
        }
    }
}

