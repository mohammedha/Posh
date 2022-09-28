# 

$service = get-wmiObject -query 'select * from SoftwareLicensingService'
if ($key = $service.OA3xOriginalProductKey) {
    Write-Host 'Product Key:' $service.OA3xOriginalProductKey
    $service.InstallProductKey($key)
}
else {
    Write-Host 'Key not found.'
}