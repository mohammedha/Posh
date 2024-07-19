
function New-3WordsPassword {

    <#
    .SYNOPSIS
    Generate a password with a random combination of words, symbols, and numbers
    Inspired by https://www.mapletech.co.uk/tools/password-generator/
    
    .DESCRIPTION
    The New-3WordsPassword function generates a password with a random combination of words, symbols, and numbers. The function accepts the following parameters:
    -Words: The number of words to include in the password. Default is 3. [300 words in total [5/6/7 letters words]]
    -Symbols: If present, a random symbol is added to the password. Default is $false.
    -Numbers: If present, a random number is added to the password. Default is $false.
    -All: If present, a random symbol and a random number is added to the password. Default is $false.
    
    .PARAMETER Words
    The number of words to include in the password. Default is 3.
    
    .PARAMETER Symbols
    Whether to include symbols in the password.
    
    .PARAMETER Numbers
    Whether to include numbers in the password.
    
    .EXAMPLE
    New-3WordsPassword -Words 4
    Generates a password with 4 words.
    
    .EXAMPLE
    New-3WordsPassword -Words 2 -All
    Generates a password with 2 words, symbols and numbers.
    
    .EXAMPLE
    New-3WordsPassword -Words 3 -Symbols
    Generates a password with 3 words, symbols and no numbers.
    
    .EXAMPLE
    New-3WordsPassword -Words 3 -Numbers
    Generates a password with 3 words, numbers and no symbols.
    .OUTPUTS
    System.String
    .NOTES
    Author: Mohamed Hassan
    Website: powershellProdigy.wordpress.com
    Date: 17/07/2024
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False)]
        [int]$Words = 3,
        [Switch]$Symbols = $False,
        [Switch]$Numbers = $False,
        [Switch]$All = $False
    )
    
    begin {
        $WordsArray = 'Fairy' , 'Awful' , 'Speed' , 'Trick' , 'Wagon' , 'Muggy' , 'Cream' , 'Craft' , 'Climb' , 'Brink' , 'Steak' , 'Sharp' , 'Title' , 'Utter' , 'Month' , 'Leave' , 'Whole' , 'Count' , 'Stamp' , 'Dough' , 'Motif' , 'Tower' , 'Witch' , 'Trunk' , 'Raise' , 'Elite' , 'Harsh' , 'Grace' , 'Spite' , 'Build' , 'Bread' , 'Still' , 'Noble' , 'Linen' , 'Decay' , 'Slice' , 'Sheep' , 'Urine' , 'Sport' , 'Rugby' , 'Cable' , 'Fault' , 'Check' , 'Chain' ,
        'Bland' , 'Final' , 'Enter' , 'Stake' , 'Rifle' , 'Throw' , 'Lease' , 'Table' , 'Beach' , 'Basic' , 'Guess' , 'Aisle' , 'Dance' , 'Basin' , 'Cheat' , 'Sword' , 'Close' , 'Steel' , 'Ideal' , 'Other' , 'Prize' , 'Delay' , 'Chord' , 'Knife' , 'Guard' , 'Swell' , 'Waist' , 'Anger' , 'Abbey' , 'Treat' , 'Deter' , 'Fibre' , 'Embox' , 'Laser' , 'Acute' , 'Sound' , 'Stick' , 'Leash' , 'Worry' , 'Opera' , 'Youth' , 'Dozen' , 'Split' , 'Serve' ,
        'Drive' , 'Glove' , 'Piece' , 'Shell' , 'Large' , 'Print' , 'Cross' , 'Cower' , 'Cruel' , 'Judge' , 'Donor' , 'Field' , 'Blank' , 'Ditch' , 'Smell' , 'Organ' , 'Touch' , 'Trail' , 'Grind' , 'Steam' , 'Sting' , 'Brake' , 'Smoke' , 'Worth' , 'Clerk' , 'Disco' , 'Plane' , 'Gaffe' , 'Obese' , 'Woman' , 'Tooth' , 'Bowel' , 'Medal' , 'Forge' , 'Thumb' , 'Miner' , 'Reign' , 'Feast' , 'Death' , 'Forum' , 'Wheel' , 'Evoke' , 'Quota' , 'Track' ,
        'Sight' , 'Sugar' , 'Grief' , 'Punch' , 'Mayor' , 'River' , 'Tiger' , 'Toast' , 'Flour' , 'Patch' , 'Panic' , 'Shelf' , 'Tease' , 'Aloof' , 'Smart' , 'Lemon' , 'Glass' , 'Enemy' , 'Margin' , 'Attack' , 'Deputy' , 'Tablet' , 'Preach' , 'Bounce' , 'Seller' , 'Stitch' , 'Defend' , 'Minute' , 'Detail' , 'Cattle' , 'Resist' , 'Throne' , 'Devote' , 'Moment' , 'Cinema' , 'Finger' , 'Ignore' , 'Bishop' , 'Turkey' , 'Revive' , 'Racism' ,
        'Double' , 'Vessel' , 'Guitar' , 'Coerce' , 'Embark' , 'Theory' , 'Infect' , 'Strain' , 'Elapse' , 'Occupy' , 'Arrest' , 'Engine' , 'Mutter' , 'Height' , 'Sector' , 'Summer' , 'Insure' , 'Leader' , 'Script' , 'Sister' , 'Suntan' , 'Hotdog' , 'Wonder' , 'Oppose' , 'Decade' , 'Revoke' , 'Banana' , 'Jungle' , 'Mosaic' , 'Battle' , 'Resign' , 'Mutual' , 'Mobile' , 'Honest' , 'Market' , 'Lounge' , 'Speech' , 'Patent' , 'Series' ,
        'Sodium' , 'Regard' , 'Pigeon' , 'Canvas' , 'Extort' , 'Voyage' , 'Stroke' , 'Invite' , 'Sacred' , 'Threat' , 'Ethics' , 'Shadow' , 'Driver' , 'Ballet' , 'Denial' , 'Create' , 'Sermon' , 'Insist' , 'Credit' , 'Answer' , 'Singer' , 'Notice' , 'Sphere' , 'Breeze' , 'Refuse' , 'Expect' , 'Reader' , 'Summit' , 'Nuance' , 'Thesis' , 'Thanks' , 'Ethnic' , 'Peanut' , 'Tactic' , 'Memory' , 'Borrow' , 'Tongue' , 'Leaflet' , 'Message' ,
        'Feature' , 'Despise' , 'Offense' , 'Regular' , 'Traffic' , 'Company' , 'Laborer' , 'Indulge' , 'Dictate' , 'Stomach' , 'Capital' , 'Perfume' , 'Abandon' , 'Citizen' , 'Explain' , 'Provide' , 'Neglect' , 'Bathtub' , 'Radical' , 'Costume' , 'Bedroom' , 'Endorse' , 'Failure' , 'Steward' , 'Extract' , 'Referee' , 'Section' , 'Warning' , 'Suspect' , 'Undress' , 'Suggest' , 'Courage' , 'Plastic' , 'Assault' , 'Tension' , 'Whisper' ,
        'Inspire' , 'Example' , 'Breathe' , 'Receipt' , 'Session' , 'Hostage' , 'Eternal' , 'Harvest' , 'Haircut' , 'Variant' , 'Article' , 'Harmful' , 'Pursuit' , 'Percent' , 'Curtain' , 'Gesture' , 'Abolish' , 'Distant' , 'Chapter' , 'Diamond' , 'Economy' , 'Penalty' , 'Perfect' , 'Witness' , 'Confine' , 'Wriggle' , 'Average' , 'Vehicle' , 'Passage' , 'Missile' , 'Partner' , 'Passive' , 'Laundry' , 'Habitat' , 'Problem' , 'Protest' ,
        'Biology' , 'Distort' , 'Variety' , 'Cabinet' , 'Texture' , 'Comfort' , 'Parking' , 'Genuine' , 'Fortune' , 'Applaud' , 'Project' , 'Certain' , 'Terrace' , 'Rubbish' , 'Voucher' , 'Trouser' , 'Posture' , 'Factory' , 'Fitness' , 'Arrange' , 'Grounds' , 'Royalty' , 'Uniform' , 'Physics' , 'Program' , 'Glasses' , 'Custody'
        $SymbolsArray = ([char]33 .. [char]47) + ([char]58 .. [char]64) + [char]91 .. [char]96 + [char]123 .. [char]126
        $NumbersArray = 1..100
    }
    
    process {
        if ($Symbols) {
            $Password = (((Get-Random -InputObject $WordsArray -Count $Words) -join ''), ((Get-Random -InputObject $SymbolsArray -Count 2) -join '')) -join ''
            Write-Output -InputObject $Password
        }
        elseif ($Numbers) {
            $Password = (((Get-Random -InputObject $WordsArray -Count $Words) -join ''), (Get-Random -InputObject $NumbersArray -Count 1) ) -join ''
            Write-Output -InputObject $Password
        }
        elseif ($All) {
            $Password = (((Get-Random -InputObject $WordsArray -Count $Words) -join ''), ((Get-Random -InputObject $SymbolsArray -Count 2) -join ''), (Get-Random -InputObject $NumbersArray -Count 1) ) -join ''
            Write-Output -InputObject $Password
        }
        else {
            $Password = ((Get-Random -InputObject $WordsArray -Count $Words) -join '')
            Write-Output -InputObject $Password
        }
        
    }
    
    end {
        
    }
}


