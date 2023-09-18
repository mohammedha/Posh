<#
.SYNOPSIS
  Create a scheduled task to run Adobe Remote Update Manager.

.DESCRIPTION
  Create a scheduled task to run Adobe Remote Update Manager every 4 weeks on Monday at 8:00 AM indiferently.

.PARAMETER $ActionParam
  Start Adobe Remote Update Manager

.PARAMETER $ActionParam2
  Terminates All Running Adobe CC Apps.

.PARAMETER $SettingsParam
  Scheduled Task Settings.

  .INPUTS
  None

.OUTPUTS
  None

.NOTES
  Version       : 1.0
  Author        : Mohamed Hassan
  Creation Date : 2023-03-21
  Purpose       : Create a scheduled task to run Adobe Remote Update Manager.
#>

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Define task action
$ActionParam = @{
    Execute = "C:\Program Files (x86)\Common Files\Adobe\OOBE_Enterprise\RemoteUpdateManager\RemoteUpdateManager.exe"
}

# Define task action2
$ActionParam2 = @{
    Execute  = "cmd.exe"
    Argument = '/C taskkill /im "Acrobat.exe" /f /t & (taskkill /im "Photoshop.exe" /f /t & (taskkill /im "Illustrator.exe" /f /t & taskkill /im "InDesign.exe" /f /t & taskkill /im "Adobe Premiere Pro.exe" /f /t & taskkill /im "AfterFX.exe" /f /t))'
}

# Define task trigger
$TriggerParam = @{
    Weekly        = $true
    At            = "08:00AM"
    WeeksInterval = 4
    DaysOfWeek    = "Monday"
    RandomDelay   = "1"
}

# Define task settings
$SettingsParam = @{
    AllowStartIfOnBatteries    = $true
    DontStopIfGoingOnBatteries = $true
}

# Construct task
$Register = @{
    Action      = (New-ScheduledTaskAction @ActionParam2), (New-ScheduledTaskAction @ActionParam)
    Trigger     = (New-ScheduledTaskTrigger @TriggerParam)
    Settings    = (New-ScheduledTaskSettingsSet @SettingsParam)
    User        = "NT AUTHORITY\SYSTEM"
    TaskName    = "AdobeRUM"
    Description = "Remote Update Manager Keeps your Adobe software up to date. If this task is disabled or stopped, your Adobe software will not be kept up to date, meaning security vulnerabilities that may arise cannot be fixed and features may not work."
    RunLevel    = "Highest"
    Force       = $true
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# Register task
Register-ScheduledTask @Register


# UNRegister task
# Unregister-ScheduledTask -TaskName "AdobeRUM" -Confirm:$false -ErrorAction SilentlyContinue
