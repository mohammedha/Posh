# Logs to extract from server
$logArray = @("System", "Security", "Application")

# Grabs the server name to append to the log file extraction
$servername = $env:computername

# Provide the path with ending "\" to store the log file extraction.
$destinationpath = "C:\temp\BACKUPS\EventLogs\$env:computername\"

# Checks the last character of the destination path.  If it does not end in '\' it adds one.
# '.+?\\$' +? means any character \\ is looking for the backslash $ is the end of the line charater
if ($destinationpath -notmatch '.+?\\$') {
    $destinationpath += '\'
}

# If the destination path does not exist it will create it
if (!(Test-Path -Path $destinationpath)) {
    New-Item -ItemType directory -Path $destinationpath
}

# Get the current date in YearMonthDay format
$logdate = Get-Date -format yyyyMMdd-HHmm

# Start Process Timer
$StopWatch = [system.diagnostics.stopwatch]::startNew()

# Start Code
Clear-Host

Foreach ($log in $logArray) {
    # If using Clear and backup
    $destination = $destinationpath + $servername + "-" + $log + "-" + $logdate + ".evtx"
    Write-Information "[INFO] Extracting the $log file now."  -InformationAction Continue
    # Extract each log file listed in $logArray from the local server.
    wevtutil epl $log $destination
    # Clear the log and backup to file.
    # Write-Information "[INFO] Clearing the $log file now." -InformationAction Continue
    # WevtUtil cl $log

}

# Compress the log files
Compress-Archive -Path $destinationpath -DestinationPath ($destinationpath + $servername + "-" + $logdate + ".zip")
remove-item $destinationpath -Recurse -Force -Exclude *.zip


# End Code
# Stop Timer
$StopWatch.Stop()
$TotalTime = $StopWatch.Elapsed.TotalSeconds
$TotalTime = [math]::Round($totalTime, 2)
Write-Information "[INFO] The Script took $TotalTime seconds to execute."  -InformationAction Continue

