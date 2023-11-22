# Specify inactivity range value below
$DaysInactive = Read-Host "Enter number of days inactive,e.g. 90"

# $time variable converts $DaysInactive to LastLogonTimeStamp property format for the -Filter switch to work
$time = (Get-Date).Adddays(-($DaysInactive))

# Identify and collect inactive computer accounts:
Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -ResultPageSize 2000 -resultSetSize $null -Properties Name, SamAccountName, DistinguishedName, LastLogonDate| Export-CSV "C:\Temp\InactiveComputers_$($daysInactive).CSV" -NoTypeInformation