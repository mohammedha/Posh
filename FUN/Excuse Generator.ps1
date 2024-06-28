$Intro = @"
Sorry, I can't come,
Please forgive my absence,
This is going to sound crazy, but
Get this:
I can't go because,
I know you're going to hate me, but
I was minding my own business, and BOOM!,
I feel terrible, but
I regretfully cannot attend,
This is going to sound like an excuse, but
"@ -split [environment]::NewLine # or -split "`n"

$Scapegoat = @"
my nephew
the ghost of Hitler
the Pope
my ex
Dan Rather
a sad clown
the kid from Air Bud
a professional cricket team
my Tinder date
Donald Trump
Barak Obama
Nigel Farage
my wife
"@ -split [environment]::NewLine # or -split "`n"

$Delay = @"
just shit the bed.
died in front of me.
won't stop telling knock-knock jokes.
is having a nervous breakdown
gave me syphilis.
poured lemonade in my gas tank.
stabbed me.
found my box of human teeth.
stole my bicycle.
posted my nudes on instagram.
pulled the plug off my inflated pool.
pulled my toe nail with a tweezers.
shaved my eyebrows while I was asleep.
pissed in my gas tank.
"@ -split [environment]::NewLine # or -split "`n"


#Function SplitList { ($Args) }
#Function SplitList { ($Args).Split("`n|`r", [System.StringSplitOptions]::RemoveEmptyEntries) }
#Function Excuse { Write-Host "$(SplitList $Intro | Get-Random) $(SplitList $Scapegoat | Get-Random) $(SplitList $Delay | Get-Random)"}
Function Excuse { 
    Write-Host "$($Intro | Get-Random) $($Scapegoat | Get-Random) $($Delay | Get-Random)"
}

Excuse
