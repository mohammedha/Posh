
# FIND WINDOWS SERVICES CONFIGURED TO RUN AS ANOTHER USER
$Servers = "DC21", "DC22"
$ServiceName = @{ Name = 'ServiceName'; Expression = { $_.Name } }
$ServiceDisplayname = @{ Name = 'Service DisplayName'; Expression = { $_.Caption } }
$ScriptBlock = { Get-CimInstance -Class Win32_Service -filter "StartName != 'LocalSystem' AND NOT StartName LIKE 'NT Authority%' " }

Invoke-Command $servers -ScriptBlock $ScriptBlock | Select-Object SystemName, $ServiceName, $ServiceDisplayname, StartMode, StartName, State | format-table -autosize

