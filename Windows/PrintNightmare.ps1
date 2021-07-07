
# Getting all Domain controllers
$ALLDC = (Get-ADForest).Domains | ForEach-Object { Get-ADDomainController -Filter * -Server $_ }

# Checking if PrintNightmare were attempts
ForEach ($DomainController in $ALLDC) {
    Write-Information -MessageData "Checking $DomainController..." -InformationAction Continue
    if (Test-Connection -ComputerName $DomainController.hostname -Quiet -Count 1 -BufferSize 16) {
        try {
            $Attempts = Get-WinEvent -LogName 'Microsoft-Windows-PrintService/Admin' -ComputerName $DomainController | Select-String -InputObject { $_.message } -Pattern 'The print spooler failed to load a plug-in module'
            if ($Attempts) {
                Write-Warning -Message "Attempts were made."
                $Attempts
            }
            else {
                Write-Information -Message "No Attempts were made." -InformationAction Continue
            }
        }
        catch {
            Write-Warning -Message "Unable to get Eventlog from $DomainController."
        }
    }
    else {
        Write-Information -MessageData "$DomainController is offline." -InformationAction Continue
    }
}

# Metigation to be run on indvidual DC#

# Find vulnerable machines
try {
    $Vulnerable = $false
    if (Get-Service -name spooler -ComputerName $DomainController | Where-Object { $_.status -eq 'Running' }) {
        $Vulnerable = $true
    }
}
catch {
    $error[0].exception.message
    Write-Information -MessageData "The spooler service is not reachable on $DomainController" -InformationAction Continue
}

# Find Shared printers
try {
    $hasPrintersShared = $false
    if (Get-Printer -ComputerName $DomainController | Where-Object -Property shared -EQ $true) {
        $hasPrintersShared = $true
    }
}
catch {
    $error[0].exception.message
    Write-Information -MessageData "The spooler service is not reachable." -InformationAction Continue
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







