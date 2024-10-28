# Copy SteamVR files to Steam folder

Copy-Item -Path "SteamVR" -Destination "C:\Program Files (x86)\Steam\steamapps\common" -Force -Recurse

# create Shortcut
function Set-ShortCut {
    [CmdletBinding()]
    param(
        [string]$SourceExe, [string]$DestinationPath
    )
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($DestinationPath)
    $Shortcut.TargetPath = $SourceExe
    $Shortcut.IconLocation = ("C:\Program Files (x86)\Steam\steamapps\common\bin\win64\VR.ico")
    $Shortcut.Save()
}
    
$PublicDesktop = $env:public + "\desktop"
Set-ShortCut "C:\Program Files (x86)\Steam\steamapps\common\bin\win64\vrstartup.exe" "$PublicDesktop\SteamVR.lnk"
