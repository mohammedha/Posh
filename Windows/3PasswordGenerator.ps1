
function New-Password {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        $Words = 'Peasant' , 'Staircase' , 'Harvest' , 'Captivate' , 'Appreciate' , 'Drop' , 'Store' , 'Buttocks' , 'Despair' , 'Beat' , 'Training' , 'Suitcase' , 'Cause' , 'Protest' , 'Mosaic' , 'Mess' , 'Forward' , 'Linger' , 'Knee' , 'Load' , 'Acute' , 'Plot' , 'Hit' , 'Swop' , 'Mention' , 'Seek' , 'Space' , 'Swear' , 'Report' , 'Flush' , 'Arrange' , 'Motif' , 'Soldier' , 'Destruction' , 'Module' ,
        'Disappear' , 'Flawed' , 'Compose' , 'Minority' , 'Venture' , 'Obligation' , 'Like' , 'Country' , 'Dominate' , 'Urine' , 'Strap' , 'Outline' , 'Appendix' , 'Dismiss' , 'Rate' , 'Kidney' , 'Occupy' , 'Variant' , 'Dash' , 'Money' , 'Suggest' , 'Aquarium' , 'Narrow' , 'Blind' , 'Size' , 'Insurance' , 'Court' , 'Inappropriate' , 'Reach' , 'Redeem' , 'Pour' , 'Stuff' , 'Oral' , 'Worker' , 'Add' ,
        'Arrangement' , 'Embark' , 'Finger' , 'Trend' , 'Trap' , 'Evaluate' , 'Responsibility' , 'Foreigner' , 'Wash' , 'Profit' , 'Try' , 'Board' , 'Rush' , 'Recognize' , 'Expertise' , 'Screw' , 'Post' , 'Lobby' , 'Enfix' , 'Fossil' , 'Integration' , 'Illness' , 'Increase' , 'Break' , 'Bland' , 'Brick' , 'Sword' , 'Favorable' , 'Express' , 'Tissue' , 'Appetite' , 'Tree' , 'Pawn' , 'Determine' , 'Strength' ,
        'Dismissal' , 'Official' , 'Sample' , 'Soak' , 'Power' , 'Shame' , 'Bride' , 'Bridge' , 'Mystery' , 'Calm' , 'Genetic' , 'Note' , 'Mine' , 'Dealer' , 'Graduate' , 'Lay' , 'Liberty' , 'Deal' , 'Dry' , 'Swallow' , 'Irony' , 'Honor' , 'Dependence' , 'Item' , 'Farewell' , 'Confusion' , 'Unlawful' , 'Mutter' , 'Galaxy' , 'Package' , 'Grandfather' , 'Confession' , 'Europe' , 'Employ' , 'Price' , 'Struggle' ,
        'Fever' , 'Sentiment' , 'Offset' , 'Jockey' , 'Aviation' , 'Stroll' , 'Confront' , 'Spin' , 'Sickness' , 'Include' , 'Useful' , 'Sock' , 'Plane' , 'Heart' , 'Survey' , 'Perforate' , 'Complication' , 'Stable' , 'Trench' , 'Cope' , 'Player' , 'Director' , 'Safety' , 'Bean' , 'Institution' , 'Dive' , 'Concentrate' , 'Girl' , 'Palace' , 'Expand' , 'Gift' , 'Thrust' , 'Declaration' , 'Virus' , 'Play' ,
        'Orientation' , 'Medal' , 'Uniform' , 'Pair' , 'Rank' , 'Square' , 'Minister' , 'Shortage' , 'Compact' , 'Wheel' , 'Timber' , 'Prosper' , 'Talented' , 'Card' , 'First' , 'Helmet' , 'Network' , 'Inquiry' , 'Twilight' , 'Innovation' 
        $Symbols = '!' , '@' , '#' , '$' , '%' , '^' , '&' , '*' , '(' , ')' , '-' , '_' , '+' , '=' , '{' , '}' , '[' , ']' , '|' , ';' , ':' , '<' , '>' , '?' , '/' , '~' , '#'
        $numbers = 1..100

    }
    
    process {
        
        $password = ((Get-Random -InputObject $Words -Count 1), (Get-Random -InputObject $Words -Count 1), (Get-Random -InputObject $Words -Count 1), (Get-Random -InputObject $Symbols -Count 1), (Get-Random -InputObject $numbers -Count 1) ) -join ''
        Write-Output -InputObject $password
    }
    
    end {
        
    }
}


New-Password 