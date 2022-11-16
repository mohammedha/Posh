function spin {
    [CmdletBinding()]
    param ([Parameter(Mandatory, Position = 0)]
        [int]$Seconds
        
    )

    begin {
        $spinners = @( "-", "\", "|", "/")
        $CursorPos = New-Object System.Management.Automation.Host.Coordinates
        $CursorPos.X = $host.ui.rawui.CursorPosition.X
        $CursorPos.Y = $host.ui.rawui.CursorPosition.Y  
        
    }
    
    process {
        # Counter code
        for ($i = 0; $i -lt $Seconds; $i++) {
            #$host.ui.rawui.CursorPosition = $CursorPos 
            if ($CurrentSpinnerIndex -ge $spinners.Count) {
                $CurrentSpinnerIndex = 0
            }
            $CurrentSpinner = $spinners["$CurrentSpinnerIndex"]
            $CurrentSpinnerIndex++
            Write-Host "Progress: [$("." * $CursorPos.X) $i% $CurrentSpinner]" -NoNewline -ForegroundColor Yellow 
            Start-Sleep -Milliseconds 100
            $CursorPos.X++
            clear-host
            
            
        }
    }
    
    end {
        
    }
}

spin 100


