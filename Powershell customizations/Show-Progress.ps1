function Show-Progress {

    <#
.SYNOPSIS
    Displays the completion status for a running task.
.DESCRIPTION
    Show-Progress displays the progress of a long-running activity, task, 
    operation, etc. It is displayed as a progress bar, along with the 
    completed percentage of the task. It displays on a single line (where 
    the cursor is located). As opposed to Write-Progress, it doesn't hide 
    the upper block of text in the PowerShell console.
.PARAMETER Activity
    A label you can assign to the current task. Normally, you'd put a relevant 
    description of what you're trying to accomplish (like "Restarting computers", 
    or "Downloading Updates").
.PARAMETER PercentComplete
    Percentage to evaluate against the parameter total. It can be a number of 
    members processed from a collection, a partial download, the current number of 
    completed tasks, etc.
.PARAMETER Total
    This is the number to evaluate against. It can be the number of users in a 
    group, total number of bytes to download, total number of tasks to execute, etc.
.PARAMETER RefreshInterval
    Amount of time between two 'refreshes' of the percentage complete and update
    of the progress bar. The default refresh interval is 1 second.
.EXAMPLE
    Show-Progress
    Without any arguments, Show-Progress displays a progress bar for 100 seconds.
    If no value is provided for the Activity parameter, it will simply say 
    "Current Task" and the completion percentage.
.EXAMPLE
    Show-Progress -PercentComplete ($WsusServer.GetContentDownloadProgress()).DownloadedBytes -Total ($WsusServer.GetContentDownloadProgress()).TotalBytesToDownload -Activity "Downloading WSUS Updates"
    Displays a progress bar while WSUS downloads updates from an upstream source.
.NOTES
    Author: Emanuel Halapciuc
    Last Updated: July 5th, 2021
#>

    Param(
        [Parameter()][string]$Activity = "Current Task",
        [Parameter()][ValidateScript({ $_ -gt 0 })][long]$PercentComplete = 1,
        [Parameter()][ValidateScript({ $_ -gt 0 })][long]$Total = 100,
        [Parameter()][ValidateRange(1, 60)][int]$RefreshInterval = 1
    )

    Process {    
        #Continue displaying progress on the same line/position
        $CurrentLine = $host.UI.RawUI.CursorPosition
        #Width of the progress bar
        if ($host.UI.RawUI.WindowSize.Width -gt 70) { $Width = 50 }
        else { $Width = ($host.UI.RawUI.WindowSize.Width) - 20 }
        if ($Width -lt 20) { "Window size is too small to display the progress bar"; break }
        $Percentage = ($PercentComplete / $Total) * 100
        #Write-Host -ForegroundColor Magenta "Percentage: $Percentage"
        for ($i = 0; $i -le 100; $i += $Percentage) {
        
            $Percentage = ($PercentComplete / $Total) * 100
            $ProgressBar = 0
            $host.UI.RawUI.CursorPosition = $CurrentLine
        
            Write-Host -NoNewline -ForegroundColor Cyan "["
            while ($ProgressBar -le $i * $Width / 100) {
                Write-Host -NoNewline "="
                $ProgressBar++
            }
            while (($ProgressBar -le $Width) -and ($ProgressBar -gt $i * $Width / 100)  ) {
                Write-Host -NoNewline " "
                $ProgressBar++
            }        
            #Write-Host -NoNewline $i
            Write-Host -NoNewline -ForegroundColor Cyan "] "
            Write-Host -NoNewline "$Activity`: "
        
            Write-Host -NoNewline "$([math]::round($i,2)) %, please wait"
        
            Start-Sleep -Seconds $RefreshInterval
            #Write-Host ""
        } #for
        #
        $host.UI.RawUI.CursorPosition = $CurrentLine
    
        Write-Host -NoNewline -ForegroundColor Cyan "["
        while ($end -le ($Width)) {
            Write-Host -NoNewline -ForegroundColor Green "="
            $end += 1
        }
        Write-Host -NoNewline -ForegroundColor Cyan "] "
        Write-Host -NoNewline "$Activity complete                    "
        #>
    } #Process

} #function