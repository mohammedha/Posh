
# Set The Domain To Search For Gpos 
$Domainname = $Env:Userdnsdomain 

# Find All Gpos In The Current Domain 
Write-Host "[$((Get-Date).TimeofDay)] INFO: Finding All The Gpos In $Domainname" -ForegroundColor Yellow
Import-Module Grouppolicy 
$Allgposindomain = Get-Gpo -All -Domain $Domainname 
$Path = Read-Host "Where Do You Want To Backup GPO?"

# Create Folders
$Date = (Get-Date).Tostring('dd.MM.yyyy')
$Gpo = New-Item -Itemtype "Directory" -Path "$Path\Gpo.Backup.$Date"

# Backing Up Gpo
Write-Host "[$((Get-Date).TimeofDay)] INFO: Backing Up All The Gpos In $Domainname" 
Set-Location -Path $path
Foreach ($Allgpos In $Allgposindomain) {
    Write-Host "[$((Get-Date).TimeofDay)] INFO: Backing Up ("$Allgpos.Displayname")"
    New-Item -ItemType "Directory" -Path "$Gpo\$($Allgpos.Displayname)"
    Backup-Gpo -Name $Allgpos.Displayname -Path "$Gpo\$($Allgpos.Displayname)" -Comment "Monthly Backup"
    Get-GPOReport -Name $Allgpos.Displayname -ReportType HTML -Path "$($GPO.Fullname)\$($Allgpos.Displayname)\$($Allgpos.Displayname).html" 
}

Set-Location -Path "C:\"
Clear-Host
$GPOsCount = Get-ChildItem -Path $Gpo | Measure-Object
Write-host "`n[INFO] $($GPOsCount.Count) GPOs have been backed up to $Gpo" -ForegroundColor Yellow
