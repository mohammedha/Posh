<#
.SYNOPSIS
Shows a simple menu to the user.

.DESCRIPTION
Shows a simple menu to the user. The menu options are hardcoded for now, but could be made dynamic in the future.

This PowerShell script is a simple menu-driven program. Here's a breakdown of how it works:

**Functions**
1. `Show-Menu`: Displays a menu with options 1 to 5, asking the user to choose an option.
2. `Get-UserChoice`: Reads the user's input and returns it as a string.
3. `Confirm-Choice`: Takes the user's input as an integer and checks if it's a valid choice (1 to 5). If valid, it displays a confirmation message and returns `$true`. If invalid, it displays an error message and returns `$false`.

**Main Loop**
The script runs an infinite loop (`while ($true)`) that:
1. Calls `Show-Menu` to display the menu.
2. Calls `Get-UserChoice` to read the user's input.
3. Checks if the input is a digit using a regular expression (`-match "^\d+$"`). If not, it displays an error message.
4. If the input is a digit, it converts it to an integer and passes it to `Confirm-Choice`.
5. If `Confirm-Choice` returns `$true`, the loop exits. Otherwise, it continues to the next iteration.

**Exit Condition**
The loop exits when the user chooses a valid option (1 to 5) and `Confirm-Choice` returns `$true`. If the user chooses option 5, the script exits with a goodbye message.

Overall, this script provides a simple text-based menu for the user to interact with, and it validates the user's input to ensure it's a valid choice.

.EXAMPLE
Show-Menu

Shows the menu to the user.

#>
function Show-Menu {
    Write-Host "Please choose an option:"
    Write-Host "1. Option 1"
    Write-Host "2. Option 2"
    Write-Host "3. Option 3"
    Write-Host "4. Option 4"
    Write-Host "5. Exit"
    Write-Host "Enter the number of your choice:"
}

function Get-UserChoice {
    $choice = Read-Host
    return $choice
}

function Confirm-Choice {
    param (
        [int]$choice
    )
    switch ($choice) {
        1 { Write-Host "You have chosen Option 1."; return $true }
        2 { Write-Host "You have chosen Option 2."; return $true }
        3 { Write-Host "You have chosen Option 3."; return $true }
        4 { Write-Host "You have chosen Option 4."; return $true }
        5 { Write-Host "Exiting the menu. Goodbye!"; exit }
        default { Write-Host "Invalid choice. Please try again."; return $false }
    }
}

while ($true) {
    Show-Menu
    $userChoice = Get-UserChoice

    if ($userChoice -match "^\d+$") {
        $userChoice = [int]$userChoice
        $isValidChoice = Confirm-Choice -choice $userChoice
        if ($isValidChoice) {
            break
        }
    }
    else {
        Write-Host "Invalid input. Please enter a number."
    }
}
