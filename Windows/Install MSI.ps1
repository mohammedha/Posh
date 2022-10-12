$Script:file = "C:\temp\XrevFreebiesSetup_2.8.0_x64.msi"
function Install-MSI {
    [CmdletBinding()]
    param ($file
    )
    begin {
        $DataStamp = get-date -Format yyyyMMddTHHmmss
        $logFile = '{0}-{1}.log' -f $file, $DataStamp
        $MSIArguments = @(
            "/i"
            ('"{0}"' -f $file)
            "/qn"
            "/norestart"
            "/L*v"
            $logFile
        )
    }
    process {
        Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 
    }
}
