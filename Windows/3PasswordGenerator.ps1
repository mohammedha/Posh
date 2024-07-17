
function New-3WordsPassword {

    <#
    .SYNOPSIS
    Generate a password with a random combination of words, symbols, and numbers
    
    .DESCRIPTION
    The New-3WordsPassword function generates a password with a random combination of words, symbols, and numbers. The function accepts the following parameters:
    -Words: The number of words to include in the password. Default is 3.
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
        $WordsArray = 'Peasant' , 'Staircase' , 'Harvest' , 'Captivate' , 'Appreciate' , 'Drop' , 'Store' , 'Buttocks' , 'Despair' , 'Beat' , 'Training' , 'Suitcase' , 'Cause' , 'Protest' , 'Mosaic' , 'Mess' , 'Forward' , 'Linger' , 'Knee' , 'Load' , 'Acute' , 'Plot' , 'Hit' , 'Swop' , 'Mention' , 'Seek' , 'Space' , 'Swear' , 'Report' , 'Flush' , 'Arrange' , 'Motif' , 'Soldier' , 'Destruction' , 'Module' ,
        'Disappear' , 'Flawed' , 'Compose' , 'Minority' , 'Venture' , 'Obligation' , 'Like' , 'Country' , 'Dominate' , 'Urine' , 'Strap' , 'Outline' , 'Appendix' , 'Dismiss' , 'Rate' , 'Kidney' , 'Occupy' , 'Variant' , 'Dash' , 'Money' , 'Suggest' , 'Aquarium' , 'Narrow' , 'Blind' , 'Size' , 'Insurance' , 'Court' , 'Inappropriate' , 'Reach' , 'Redeem' , 'Pour' , 'Stuff' , 'Oral' , 'Worker' , 'Add' ,
        'Arrangement' , 'Embark' , 'Finger' , 'Trend' , 'Trap' , 'Evaluate' , 'Responsibility' , 'Foreigner' , 'Wash' , 'Profit' , 'Try' , 'Board' , 'Rush' , 'Recognize' , 'Expertise' , 'Screw' , 'Post' , 'Lobby' , 'Enfix' , 'Fossil' , 'Integration' , 'Illness' , 'Increase' , 'Break' , 'Bland' , 'Brick' , 'Sword' , 'Favorable' , 'Express' , 'Tissue' , 'Appetite' , 'Tree' , 'Pawn' , 'Determine' , 'Strength' ,
        'Dismissal' , 'Official' , 'Sample' , 'Soak' , 'Power' , 'Shame' , 'Bride' , 'Bridge' , 'Mystery' , 'Calm' , 'Genetic' , 'Note' , 'Mine' , 'Dealer' , 'Graduate' , 'Lay' , 'Liberty' , 'Deal' , 'Dry' , 'Swallow' , 'Irony' , 'Honor' , 'Dependence' , 'Item' , 'Farewell' , 'Confusion' , 'Unlawful' , 'Mutter' , 'Galaxy' , 'Package' , 'Grandfather' , 'Confession' , 'Europe' , 'Employ' , 'Price' , 'Struggle' ,
        'Fever' , 'Sentiment' , 'Offset' , 'Jockey' , 'Aviation' , 'Stroll' , 'Confront' , 'Spin' , 'Sickness' , 'Include' , 'Useful' , 'Sock' , 'Plane' , 'Heart' , 'Survey' , 'Perforate' , 'Complication' , 'Stable' , 'Trench' , 'Cope' , 'Player' , 'Director' , 'Safety' , 'Bean' , 'Institution' , 'Dive' , 'Concentrate' , 'Girl' , 'Palace' , 'Expand' , 'Gift' , 'Thrust' , 'Declaration' , 'Virus' , 'Play' ,
        'Orientation' , 'Medal' , 'Uniform' , 'Pair' , 'Rank' , 'Square' , 'Minister' , 'Shortage' , 'Compact' , 'Wheel' , 'Timber' , 'Prosper' , 'Talented' , 'Card' , 'First' , 'Helmet' , 'Network' , 'Inquiry' , 'Twilight' , 'Innovation' 
        $SymbolsArray = '!' , '@' , '#' , '$' , '%' , '^' , '&' , '*' , '(' , ')' , '-' , '_' , '+' , '=' , '{' , '}' , '[' , ']' , '|' , ';' , ':' , '<' , '>' , '?' , '/' , '~' , '#'
        $NumbersArray = 1..100
    }
    
    process {
        if ($Symbols) {
            $Password = (((Get-Random -InputObject $WordsArray -Count $Words) -join ''), (Get-Random -InputObject $SymbolsArray -Count 1)) -join ''
            Write-Output -InputObject $Password
        }
        elseif ($Numbers) {
            $Password = (((Get-Random -InputObject $WordsArray -Count $Words) -join ''), (Get-Random -InputObject $NumbersArray -Count 1) ) -join ''
            Write-Output -InputObject $Password
        }
        elseif ($All) {
            $Password = (((Get-Random -InputObject $WordsArray -Count $Words) -join ''), (Get-Random -InputObject $SymbolsArray -Count 1), (Get-Random -InputObject $NumbersArray -Count 1) ) -join ''
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


