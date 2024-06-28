# Updates the curl in C:\Windows\System32 and copies the old ACL

$curlPath = 'C:\Windows\System32\curl.exe'
$updatedCurlPath = '' # Put in an accessible location for all target computers

#region Create ACL with administrator rights
$originalAcl = Get-Acl -Path $curlPath
$adminAcl = Get-Acl -Path $curlPath

$rights = 'FullControl'
$type = 'Allow'
$adminGroup = 'BUILTIN\Administrators'
$adminAccount = [System.Security.Principal.NTAccount]::new($adminGroup)

$adminFullAccessRule = [System.Security.AccessControl.FileSystemAccessRule]::new($adminGroup, $rights, $type)
$adminAcl.SetOwner($adminAccount)
$adminAcl.AddAccessRule($adminFullAccessRule)
#endregion

Set-Acl -Path $curlPath -AclObject $adminAcl
Copy-Item -Path $updatedCurlPath -Destination $curlPath -Force
Set-Acl -Path $updatedCurlPath -AclObject $originalAcl