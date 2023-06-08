$song = {While ($true) {
sleep -milliseconds 5
[console]::beep(440,500)
sleep -milliseconds 5
[console]::beep(440,500)
sleep -milliseconds 5
[console]::beep(440,500)
sleep -milliseconds 5
[console]::beep(349,350)
sleep -milliseconds 5
[console]::beep(523,150)


sleep -milliseconds 5
[console]::beep(440,500)
sleep -milliseconds 5
[console]::beep(349,350)
sleep -milliseconds 5
[console]::beep(523,150)
sleep -milliseconds 5
[console]::beep(440,1000)


sleep -milliseconds 5
[console]::beep(659,500)
sleep -milliseconds 5
[console]::beep(659,500)
sleep -milliseconds 5
[console]::beep(659,500)
sleep -milliseconds 5
[console]::beep(698,350)
sleep -milliseconds 5
[console]::beep(523,150)

sleep -milliseconds 5
[console]::beep(415,500)
sleep -milliseconds 5
[console]::beep(349,350)
sleep -milliseconds 5
[console]::beep(523,150)
sleep -milliseconds 5
[console]::beep(440,1000)

sleep -milliseconds 5
[console]::beep(880,500)
sleep -milliseconds 5
[console]::beep(440,350)
sleep -milliseconds 5
[console]::beep(440,150)
sleep -milliseconds 5
[console]::beep(880,500)
sleep -milliseconds 5
[console]::beep(830,250)
sleep -milliseconds 5
[console]::beep(784,250)

sleep -milliseconds 5
[console]::beep(740,125)
sleep -milliseconds 5
[console]::beep(698,125)
sleep -milliseconds 5
[console]::beep(740,250)

sleep -milliseconds 5
[console]::beep(455,250)
sleep -milliseconds 5
[console]::beep(622,500)
sleep -milliseconds 5
[console]::beep(587,250)
sleep -milliseconds 5
[console]::beep(554,250)

sleep -milliseconds 5
[console]::beep(523,125)
sleep -milliseconds 5
[console]::beep(466,125)
sleep -milliseconds 5
[console]::beep(523,250)

sleep -milliseconds 5
[console]::beep(349,125)
sleep -milliseconds 5
[console]::beep(415,500)
sleep -milliseconds 5
[console]::beep(349,375)
sleep -milliseconds 5
[console]::beep(440,125)

sleep -milliseconds 5
[console]::beep(523,500)
sleep -milliseconds 5
[console]::beep(440,375)
sleep -milliseconds 5
[console]::beep(523,125)
sleep -milliseconds 5
[console]::beep(659,1000)

sleep -milliseconds 5
[console]::beep(880,500)
sleep -milliseconds 5
[console]::beep(440,350)
sleep -milliseconds 5
[console]::beep(440,150)
sleep -milliseconds 5
[console]::beep(880,500)
sleep -milliseconds 5
[console]::beep(830,250)
sleep -milliseconds 5
[console]::beep(784,250)

sleep -milliseconds 5
[console]::beep(740,125)
sleep -milliseconds 5
[console]::beep(698,125)
sleep -milliseconds 5
[console]::beep(740,250)

sleep -milliseconds 5
[console]::beep(455,250)
sleep -milliseconds 5
[console]::beep(622,500)
sleep -milliseconds 5
[console]::beep(587,250)
sleep -milliseconds 5
[console]::beep(554,250)

sleep -milliseconds 5
[console]::beep(523,125)
sleep -milliseconds 5
[console]::beep(466,125)
sleep -milliseconds 5
[console]::beep(523,250)

sleep -milliseconds 5
[console]::beep(349,250)
sleep -milliseconds 5
[console]::beep(415,500)
sleep -milliseconds 5
[console]::beep(349,375)
sleep -milliseconds 5
[console]::beep(523,125)

sleep -milliseconds 5
[console]::beep(440,500)
sleep -milliseconds 5
[console]::beep(349,375)
sleep -milliseconds 5
[console]::beep(261,125)
sleep -milliseconds 5
[console]::beep(440,1000)
}}
try {
$null = start-job -name may4 -scriptblock $song
"
A long time ago in a galaxy far, far away....

"

[console]::ForegroundColor = "Yellow"
"      ________________.  ___     .______
     /                | /   \    |   _  \
    |   (-----|  |----`/  ^  \   |  |_)  |
     \   \    |  |    /  /_\  \  |      /
.-----)   |   |  |   /  _____  \ |  |\  \-------.
|________/    |__|  /__/     \__\| _| `.________|
 ____    __    ____  ___     .______    ________.
 \   \  /  \  /   / /   \    |   _  \  /        |
  \   \/    \/   / /  ^  \   |  |_)  ||   (-----`
   \            / /  /_\  \  |      /  \   \
    \    /\    / /  _____  \ |  |\  \---)   |
     \__/  \__/ /__/     \__\|__| `._______/

------------------------------------------------"


[console]::ForegroundColor = "Yellow"
$stanza1 = "
It is a period of civil war.
Rebel spaceships, striking
from a hidden base, have won
their first victory against
the evil Galactic Empire.

".ToCharArray()

foreach ($char in $stanza1){ write-host $char -NoNewline -ForegroundColor yellow; sleep -Milliseconds 125}


$stanza2 = "
During the battle, Rebel
spies managed to steal secret
plans to the Empire's
ultimate weapon, the DEATH
STAR, an armored space
station with enough power to
destroy an entire planet.
 ".ToCharArray()
foreach ($char in $stanza2){ write-host $char -NoNewline -ForegroundColor yellow; sleep -Milliseconds 125}

$stanza3 = "
Pursued by the Empire's
sinister agents, Princess
Leia races home aboard her
starship, custodian of the
stolen plans that can save
her people and restore
freedom to the galaxy....
".ToCharArray()

foreach ($char in $stanza3){ write-host $char -NoNewline -ForegroundColor yellow; sleep -Milliseconds 125}
}
finally {
stop-job -name may4
}