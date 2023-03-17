<#
This Script will retrive the uninstall code for Carbonblack Cloud

#>
#Requires -Version 6.0

Clear-Host
$Global:OrgKey = "xxxxxxxx"
$Global:APIID = "xxxxxxxxxx"
$Global:APISecretKey = "x0x0x0x0x0x0x0x0x0x0x0x0"
$Global:Hostname = "https://defense-eu.conferdeploy.net"
$Global:Headers = @{"X-Auth-Token" = "$APISecretKey/$APIID" }
$Global:Body = @{
    "deployment_type" = "ENDPOINT"
    "query"           = "$Computer"
}
$Global:Uri = "$Hostname/appservices/v6/orgs/$OrgKey/devices/_search"

$List = 'Get CBC Uninstall code', 'Exit'
foreach ($MenuItem in $List) {
    '{0} - {1}' -f ($List.IndexOf($MenuItem) + 1), $MenuItem
}

$Choice = ''
while ([string]::IsNullOrEmpty($Choice)) {
    Write-Host
    $Choice = Read-Host 'Please choose an item by number '
    if ($Choice -notin 1..$List.Count) {
        [console]::Beep(1000, 300)
        ('    Your choice [ {0} ] is not valid.' -f $Choice)
        ('        The valid choices are 1 thru {0}.' -f $List.Count)
        '        Please try again ...'
        pause
        $Choice = ''
    }
    elseif ($Choice -eq 2) {
        Return
    }
}

"`nYou chose {0}" -f $List[$Choice - 1]

$Global:Computer = Read-Host -Prompt "Please enter computer name, [e.g. PC1]"
$Global:Computer = ($Global:Computer).trim()
$Global:Ask = Read-Host -Prompt "The computer name you entered is $Global:Computer, do you want to continue? [y/n]"
if ($Global:Ask -eq "n") {
    <# Action to perform if the condition is true #>
    Write-Host "Terminating."
    Return
}
else {
    $Response = Invoke-WebRequest -Uri $Uri -Headers $Headers -Method Post -Body ($Body | ConvertTo-Json) -ContentType "application/json"
    $Data = $Response.Content | Convertfrom-Json
    ""
    Write-Host "Uninstall Code for $Computer is: " -NoNewline
    write-host $data.results.uninstall_code -ForegroundColor Yellow
}

