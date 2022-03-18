# Install App
Start-Process "VooVMeeting_3.3.2.510.exe" -ArgumentList "/S"

start-sleep 30

# copy app executable
try {
    Copy-Item "C:\Program Files (x86)\Tencent\VooVMeeting\voovmeetingapp_new.exe" "C:\Program Files (x86)\Tencent\VooVMeeting\voovmeetingapp.exe"
}
catch {
    Write-Verbose "VooVMeeting_3.3.2.510.exe still installing..." -Verbose
    start-sleep 20
}

try {
    Copy-Item "C:\Program Files (x86)\Tencent\VooVMeeting\voovmeetingapp_new.exe" "C:\Program Files (x86)\Tencent\VooVMeeting\voovmeetingapp.exe"
}
catch {
    Write-Verbose "VooVMeeting_3.3.2.510.exe still installing..." -Verbose
    start-sleep 20
}

# create Shortcut

function Set-ShortCut {
[CmdletBinding()]
param(
[string]$SourceExe, [string]$DestinationPath
)
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($DestinationPath)
$Shortcut.TargetPath = $SourceExe
$Shortcut.Save()
}

$PublicDesktop = $env:public + "\desktop"
Set-ShortCut "C:\Program Files (x86)\Tencent\VooVMeeting\voovmeetingapp.exe" "$PublicDesktop\VoovMeeting.lnk"