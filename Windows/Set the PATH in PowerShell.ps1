
$AskPath = Read-Host "please type the path"
function Add-Path($Path) {
    $Path = [Environment]::GetEnvironmentVariable("PATH", "Machine") + [IO.Path]::PathSeparator + $Path
    [Environment]::SetEnvironmentVariable( "Path", $Path, "Machine" )
}

Add-Path -Path $AskPath


# OR
function Add-PathSystemVariable {
    [CmdletBinding()]
    param (
        $Path
    )
    
    begin {
         
    }
    
    process {
        $Path = [Environment]::GetEnvironmentVariable("PATH", "Machine") + [IO.Path]::PathSeparator + $Path
        [Environment]::SetEnvironmentVariable( "Path", $Path, "Machine" )
    }
    
    end {
        Write-Information -MessageData "Completed." -InformationAction Continue
    }
}