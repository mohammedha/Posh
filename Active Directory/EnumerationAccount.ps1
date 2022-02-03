# This script will Enumerate all AD account then report members of Domain Aemins, Enterprise Admins and Scheme Admins.



[console]::bufferwidth = 32766
# Check Active Directory Module
if (!(get-module activedirectory)) {
    import-module activedirectory | Out-Null
}

# Get AD users
Get-aduser -filter * -properties * | ForEach-Object {
    "$(($_).name),$(($_).samaccountname),$(($_).description),$(($_).sid),$(($_).whencreated),$([datetime]::fromfiletime([int64] $(($_).lastlogontimestamp))),$(($_).passwordlastset),$(($_).passwordneverexpires),$(($_).emailaddress),$(($_).enabled)"
}

write-host -foregroundcolor cyan " Status|Name|SamAccountName|WhenCreated|LastLogon|PasswordLastSet "

# Get Admin users
"Domain", "Enterprise", "Schema" | ForEach-Object {
    "`n# $_ Admins"
    Get-adgroupmember -identity "$_ Admins" | ForEach-Object {
        $Enabled = $(get-aduser -identity $(($_).samaccountname)).enabled
        $Created = $(get-aduser -identity $(($_).samaccountname) -prop *).whencreated
        $PasswordLastSet = $(get-aduser -identity $(($_).samaccountname) -prop *).passwordlastset
        $PasswordNeverExpire = $(get-aduser -identity $(($_).samaccountname) -prop *).passwordneverexpires
        $Email = $(get-aduser -identity $(($_).samaccountname) -prop *).emailaddress
        $l = $(get-aduser -identity $(($_).samaccountname) -prop *).lastlogontimestamp
        if ($Enabled -match "true") {
            $color = "green"
            $status = "ENABLED"
        }
        else {
            $color = "red"
            $status = "DISABLED"
        }
        write-host -foregroundcolor $color "- $status,$(($_).name),$(($_).samaccountname),$Created,$([datetime]::fromfiletime([int64] $l)),$PasswordLastSet,$PasswordNeverExpire,$Email"
    }
}