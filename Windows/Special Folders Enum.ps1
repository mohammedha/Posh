$Collection = [Enum]::GetNames([Environment+SpecialFolder])

foreach ($currentItemName in $collection) {
    write-host "Special Folder " -NoNewline
    write-host $currentItemName  -NoNewline -ForegroundColor Yellow
    write-host " Path is " -NoNewline
    write-host "'$([Environment]::GetFolderPath($currentItemName))'" -ForegroundColor Green
}