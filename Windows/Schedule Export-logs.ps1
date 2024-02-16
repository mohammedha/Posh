# Run Export logs as a schedulled task
$Action = New-ScheduledTaskAction -Execute "PowerShell" -Argument "-NoProfile -ExecutionPolicy ByPass -File C:\SUPPORT\export-logs.ps1"
$Principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -RunLevel Highest
$Trigger = New-ScheduledTaskTrigger -Daily -At "07:00AM"

Register-ScheduledTask -TaskName "Export Logs" -Trigger $Trigger -Action $Action -Principal $Principal -Description "Export System, Security ,Application eventlogs"

