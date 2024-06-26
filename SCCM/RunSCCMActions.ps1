<#
    .Synopsis
        Run SCCM action on a selected computer 
    .DESCRIPTION
        Run SCCM action on a selected computer using WMI method
        Available SCCM Actions
        {00000000-0000-0000-0000-000000000021}	Machine policy retrieval & Evaluation Cycle
        {00000000-0000-0000-0000-000000000002}	Software inventory cycle
        {00000000-0000-0000-0000-000000000001}	Hardware inventory cycle
        {00000000-0000-0000-0000-000000000113}	Software updates scan cycle
        {00000000-0000-0000-0000-000000000114}	Software updates deployment evaluation cycle
        {00000000-0000-0000-0000-000000000121}	Application deployment evaluation cycle
        {00000000-0000-0000-0000-000000000026}	User policy retrieval
        {00000000-0000-0000-0000-000000000027}	User policy evaluation cycle
        {00000000-0000-0000-0000-000000000010}	File collection
    .EXAMPLE
        .\RunSCCMActions.ps1
        VERBOSE: Performing the operation "Invoke-WmiMethod" on target "SMS_Client (TriggerSchedule)".
        PC-418-08 - Machine policy retrieval & Evaluation Cycle - ReturnValue
        This command will run "Machine policy retrieval & Evaluation Cycle" SCCM acction on PC-418-08 
    .OUTPUTS
    [String]
    .NOTES
    Written by Mohamed Hassan
    I take no responsibility for any issues caused by this script.
    .FUNCTIONALITY
    Run SCCM action on a selected computer
    .LINK
    https://learn.microsoft.com/en-us/mem/configmgr/develop/reference/core/clients/client-classes/triggerschedule-method-in-class-sms_client
    #>

Clear-Host
[int]$Selection = ""
$ClientActions = 'Machine policy retrieval & Evaluation Cycle' , 'Software inventory cycle', 'Hardware inventory cycle', 'Application deployment evaluation cycle', 'User policy retrieval', 'User policy evaluation cycle', 'Software updates scan cycle', 'Software updates deployment evaluation cycle', 'File collection', 'Exit'
Write-Host "Select the client action you want to trigger:"
for ($i = 0; $i -lt $ClientActions.Length; $i++) {
    Write-Host "$($i+1). $($ClientActions[$i])"
}
    
[int]$Selection = Read-Host "Enter your selection (1-$($ClientActions.Length))"
    
while (([string]::IsNullOrEmpty($Selection)) -or ($Selection -notin (1..$ClientActions.Length))) {
    if ($Selection -notin 1..$ClientActions.Length) {
        [console]::Beep(1000, 300)
        Write-Output "Your choice [ $Selection ] is not valid."
        Write-Output "The valid choices are 1 thru $($ClientActions.Length)"
        Write-Output "      Please try again ..."
        pause
        [int]$Selection = Read-Host "Enter your selection (1-$($ClientActions.Length))"
    }
    
    elseif ($Selection -eq 10) {
        Return
    }
}
    
Write-host "You chose" $ClientActions[$Selection - 1]
    
    
    
# Ask for Computer name
    
$ComputerName = Read-Host "Enter the name of the computer you want to trigger the action on"
    
    
if ($Selection -eq 1) {
    $ScheduleGUID = "{00000000-0000-0000-0000-000000000021}"
    $log = "\\$ComputerName\C$\Windows\CCM\Logs\PolicyAgent.log"
}
elseif ($Selection -eq 2) {
    $ScheduleGUID = "{00000000-0000-0000-0000-000000000002}"
    $log = "\\$ComputerName\C$\Windows\CCM\Logs\Inventoryagent.log"
}
elseif ($Selection -eq 3) {
    $ScheduleGUID = "{00000000-0000-0000-0000-000000000001}"
    $log = "\\$ComputerName\C$\Windows\CCM\Logs\Appdiscovery.log"
}
elseif ($Selection -eq 4) {
    $ScheduleGUID = "{00000000-0000-0000-0000-000000000121}"
}
elseif ($Selection -eq 5) {
    $ScheduleGUID = "{00000000-0000-0000-0000-000000000026}"
}
elseif ($Selection -eq 6) {
    $ScheduleGUID = "{00000000-0000-0000-0000-000000000027}"
}
elseif ($Selection -eq 7) {
    $ScheduleGUID = "{00000000-0000-0000-0000-000000000113}"
    $log = "\\$ComputerName\C$\Windows\CCM\Logs\ScanAgent.log"
}
elseif ($Selection -eq 8) {
    $ScheduleGUID = "{00000000-0000-0000-0000-000000000114}"
    $log = "\\$ComputerName\C$\Windows\CCM\Logs\UpdateDeployment.log"
}
elseif ($Selection -eq 9) {
    $ScheduleGUID = "{00000000-0000-0000-0000-000000000010}"
}
    
$ClientAction = $ClientActions[$Selection - 1]
$TriggerAction = Invoke-WmiMethod -Namespace root\ccm -Class SMS_Client -ComputerName $ComputerName -Name TriggerSchedule -ArgumentList $ScheduleGUID
Write-Host "$($ComputerName) - $($ClientAction) - $($TriggerAction.ReturnValue)" -ForegroundColor Green
    
Write-Host "Tailing SCCM Logfile $Log" -ForegroundColor Yellow
try {
    Start-Sleep -Seconds 5
    Get-Content -Path $log -Tail 5
}
catch {
    write-host "No Log Available" -ForegroundColor Yellow
}
    
    
    