# Find which process is locking file/folder
$LockingProcess = CMD /C "openfiles /query /fo table | find /I "File/folder name""
write-host $LockingProcess