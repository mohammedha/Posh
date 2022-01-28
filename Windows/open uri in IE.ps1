# open uri in IE
$IE = new-object -com internetexplorer.application
$IE.navigate2("127.0.0.1")
$IE.visible = $true