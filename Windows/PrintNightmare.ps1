
# Getting all Domain controllers
$ALLDC = (Get-ADForest).Domains | ForEach-Object { Get-ADDomainController -Filter * -Server $_ }

# Checking if PrintNightmare were attempts
ForEach ($DomainController in $ALLDC) {
    Write-Information -MessageData "Checking $DomainController" -InformationAction Continue
    #Get-WinEvent -LogName 'Microsoft-Windows-PrintService/Admin' | Where-Object { $_.message -like "*The print spooler failed to load a plug-in module*" }
    $Attempts = Get-WinEvent -LogName 'Microsoft-Windows-PrintService/Admin' | Select-String -InputObject { $_.message } -Pattern 'The print spooler failed to load a plug-in module'
    if ($Attempts) {
        Write-Warning -Message "Attempt(s) were made."
        $Attempts
    }
    else {
        Write-Information -Message "No Attempt(s) made." -InformationAction Continue
    }
}

# Metigation #

# Find vulnerable machines
$vulnerable = $false
if (Get-Service spooler | Where-Object { $_.status -eq 'Running' }) {
    $vulnerable = $true
}

# Find Shared printers
$hasPrintersShared = $false
if (Get-Printer | Where-Object -Property shared -EQ $true) {
    $hasPrintersShared = $true
}

if ($vulnerable) {
    switch ($hasPrintersShared) {
        # Lock driver if there is shared printers
        $true {
            $path = "C:\Windows\System32\spool\drivers"
            $acl = (Get-Item $Path).GetAccessControl('Access')
            $ar = New-Object System.Security.AccessControl.FileSystemAccessRule("System", "Modify", "ContainerInherit, ObjectInherit", "None", "Deny")
            $acl.AddAccessRule($Ar)
            Set-Acl $path $acl
        }
        # Disable Spooler 
        $false {
            Stop-Service -name Spooler -force
            Set-Service -name Spooler -startuptype Disabled
        }
    }
}
