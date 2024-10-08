# Set The Domain To Search For Gpos 
$Domainname = $Env:Userdnsdomain 
$PathDFS = Read-Host "Where Do You Want To Backup DFS?"

# Create Folders
$Date = (Get-Date).Tostring('dd.MM.yyyy')
$Dfs = New-Item -Itemtype "Directory" -Path "$PathDFS\Dfs.Backup.$Date"

# Finding All Dfs Root
Write-Host "[$((Get-Date).TimeofDay)] INFO: Finding All DFS Root $Domainname" 
Set-Location -Path $DFS.FullName

# Backing Up Dfs Root - Modified Version From Ittools.Com
$configurationContainer = ([adsi] "LDAP://RootDSE").Get("ConfigurationNamingContext")
$partitions = ([adsi] "LDAP://CN=Partitions,$configurationContainer").psbase.children
foreach ($partition in $partitions) {
    if ($partition.netbiosName -ne "") {
        $partitionDN = $partition.ncName
        $dnsName = $partitionDN.toString().replace("DC=", ".").replace(",", "").substring(1)
        $domain = $partition.nETBIOSName
        "`n$domain"
        $dfsContainer = [adsi] "LDAP://cn=Dfs-Configuration,cn=System,$partitionDN"
        $dfsRoots = $dfsContainer.psbase.children
        foreach ($dfsRoot in $dfsRoots) {
            $root = $dfsRoot.cn
            Write-Host "[$((Get-Date).TimeofDay)] INFO: Backing up $root" -ForegroundColor Yellow
            dfsutil root export "\\$dnsName\$root" "c:\temp\$root.xml"
            Write-Host "[$((Get-Date).TimeofDay)] INFO: Moving $root.xml to $($dfs.FullName)" -ForegroundColor Yellow
            Move-Item "c:\temp\$root.xml" $dfs.FullName
        }
    }
}

Set-Location -Path "C:\"
Clear-Host
$DFSCount = Get-ChildItem -Path $Dfs | Measure-Object
Write-host "`n[INFO] $($DFsCount.Count) DFS root have been backed up to '$Dfs'" -ForegroundColor Yellow
