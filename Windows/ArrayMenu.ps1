
# Variables
$xPickListValues = "gmail.com", "hotmail.com", "yahoo.com", "mail.com", "outlook.com"
$array = @()
$i = 0

# Build table
foreach ($entry in $xPickListValues) {
    $array += (, ($i, $entry))
    $i = $i + 1
}

# Display table
foreach ($arrayentry in $array) {
    Write-Host $("`t`t" + $arrayentry[0] + ". " + $arrayentry[1])
}

# Ask for selection
$xPickListSelection = Read-Host "`n`t`tEnter Option Number"
$selection = $array[$xPickListSelection][1]

# Confirm selection
write-host "You selected '$selection'"

# Open Selection
[system.Diagnostics.Process]::Start("msedge", "$selection")


