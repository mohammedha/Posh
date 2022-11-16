
function Copy-ItemWithProgress {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 0, HelpMessage = "Source Path")] 
        [Alias('S')]
        $SourcePath,
        [Parameter(Mandatory = $True, Position = 0, HelpMessage = "Destination Path")] 
        [Alias('D')]
        $DestinationPath
    )
    
    begin {
        $Files = Get-ChildItem -Path $SourcePath -Recurse
$FileCount = $Files.Count
$i=0
    }
    
    process {
        Foreach ($File in $Files) {
            $i++
            $Percentage = ($i / $FileCount) * 100
            Write-Progress -activity "Copying Files..." -status "($i of $Filecount) $([math]::Round($Percentage,1)) %" -percentcomplete (($i/$Filecount)*100)
            # Determine the absolute Path of this object's parent container.  This is stored as a different attribute on File and folder objects so we use an if block to cater for both
            if ($File.PSisContainer) {$SourceFileContainer = $File.Parent} else {$SourceFileContainer = $File.Directory}
            # Calculate the Path of the parent folder Relative to the Source folder
            $RelativePath = $SourceFilecontainer.Fullname.SubString($SourcePath.Length)
            # Copy the object to the appropriate folder within the Destination folder
            copy-Item $File.Fullname ($DestinationPath + $RelativePath)
        }
    }
    
    end {
        
    }
}

Copy-ItemWithProgress -S c:\temp\ -D c:\windows

#"$([math]::Round($Percentage,1)) %"