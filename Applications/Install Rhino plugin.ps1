$Global:logfolder = "C:\Temp\"
$Global:LogFilename = "Pufferfish_3.0_Install.log"
$Global:Log = $logfolder + $LogFilename

# Log file/folder
function New-logFolder {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    if (!(Test-Path -Path $logfolder)) {
        New-Item -Path $logfolder -ItemType Directory
    }
    return $logfolder
}
function New-LogFile {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    if (!(Test-Path -Path $log )) {
        New-Item -path $Log -ItemType File
    }
    return $LogFilename
}

Write-Verbose -Message "Setting up Log folder..."
New-logFolder
Write-Verbose -Message "Creating up Log file..."
New-LogFile

function Install-Rhino7Plugin {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string]$Name
    )
    
    begin {
        $user = $env:USERNAME
        $Libraries = Get-ChildItem -Path ".\Libraries\*"
        $UserObjects = Get-ChildItem -Path ".\UserObjects\*"
        
    }
    
    process {
        # copying GH libraries files
        if (Test-Path "$env:APPDATA\Grasshopper\Libraries") {
            Write-Verbose -Message "Grasshopper\Libraries - Detected!"
            foreach ($item in $Libraries.name) {
                Write-Verbose "Copying $item"
            }
            Copy-Item -Path ".\Libraries" -Destination "$env:APPDATA\Grasshopper\Libraries\$Name\" -Recurse
        }
        else {
            Write-Error -Message "ERROR: '$env:APPDATA\Grasshopper\UserObjects' Does not exist. Start Grasshopper then try re-installing the plug-in." -Category ObjectNotFound 
        }
        # copying GH Useropbjects files
        if (Test-Path "$env:APPDATA\Grasshopper\UserObjects") {
            Write-Verbose -Message "Grasshopper\UserObjects - Detected!"
            foreach ($item in $UserObjects.name) {
                Write-Verbose "Copying $item"
            }
            Copy-Item -Path ".\UserObjects" -Destination "$env:APPDATA\Grasshopper\UserObjects\$Name\" -Recurse
        }
        else {
            Write-Error -Message "ERROR: '$env:APPDATA\Grasshopper\UserObjects' Does not exist. Start Grasshopper then try re-installing the plug-in." -Category ObjectNotFound 
        }
        
    }
    
    end {
        
    }
}
Write-Verbose "Start Transcript"
Start-Transcript -path $Log -Force -Verbose

Install-Rhino7Plugin -Name "Pufferfish" -Verbose

Write-Verbose "Stop Transcript"
Stop-Transcript
