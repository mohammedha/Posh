# https://jdhitsolutions.com/blog/powershell/9018/an-iron-scripter-warm-up-solution/
Function Invoke-ReverseText {
    [CmdletBinding()]
    [OutputType("string")]
    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            ValueFromPipeline,
            HelpMessage = "Enter a phrase."
        )]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("\s")]
        [string]$Text
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    } #begin
    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing $Text"
        #split the phrase on white spaces and reverse each word
        $words = $Text.split() | Invoke-ReverseWord
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Reversed $($words.count) words"
        ($words[-1.. - $($words.count)]) -join " "
    } #process
    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end
}

Function Invoke-ToggleCase {
    [cmdletbinding()]
    [OutputType("String")]
    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            ValueFromPipeline,
            HelpMessage = "Enter a word."
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Word
    )

    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    } #begin
    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing $Word"
        $Toggled = $Word.ToCharArray() | ForEach-Object {
            $i = $_ -as [int]
            if ($i -ge 65 -AND $i -le 90) {
                #toggle lower
                $_.ToString().ToLower()
            }
            elseif ($i -ge 97 -AND $i -le 122) {
                #toggle upper
                $_.ToString().ToUpper()
            }
            else {
                $_.ToString()
            }
        } #foreach-object

        #write the new word to the pipeline
        $toggled -join ''

    } #process
    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

}

Function Convert-Text {
    <#
    This function relies on some of the previous functions or the functions could be nested
    inside the Begin block

    Order of operation:
      toggle case
      reverse word
      reverse text
    #>
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Text,
        [Parameter(HelpMessage = "Reverse each word of text")]
        [switch]$ReverseWord,
        [Parameter(HelpMessage = "Toggle the case of the text")]
        [switch]$ToggleCase,
        [Parameter(HelpMessage = "Reverse the entire string of text")]
        [switch]$ReverseText
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Converting $Text"
        $words = $text.Split()
        if ($ToggleCase) {
            Write-Verbose "toggling case"
            $words = $words | Invoke-ToggleCase
        }
        If ($reverseWord) {
            Write-Verbose "reversing words"
            $words = $words | Invoke-ReverseWord
        }
        if ($ReverseText) {
            Write-Verbose "reversing text"
            $words = ($words[-1.. - $($words.count)])
        }
        #write the converted text to the pipeline
        $words -join " "

    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Convert-Text