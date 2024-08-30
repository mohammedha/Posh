
#Set Current Directory
$ScriptPath = $MyInvocation.MyCommand.Path
$CurrentDir = Split-Path $ScriptPath

#Set Font Reg Key Path
$FontRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

#Grab the Font from the Current Directory
foreach ($Font in $(Get-ChildItem -Path $CurrentDir -Include *.ttf, *.otf, *.fon, *.fnt -Recurse)) {

    #Copy Font to the Windows Font Directory
    Copy-Item $Font "C:\Windows\Fonts\" -Force
    
    #Set the Registry Key to indicate the Font has been installed
    New-ItemProperty -Path $FontRegPath -Name $Font.Name -Value $Font.Name -PropertyType String -Value $Font.name | Out-Null
    Write-Output "Copied: $($Font.Name)"
}

