function Get-Greeting {
    $currentTime = (Get-Date).Hour
    $username = $env:USERNAME

    # Define arrays for friendly greetings
    $morningGreetings = @("Morning $username!", "Good morning, $username!", "Rise and shine, $username!")
    $afternoonGreetings = @("Afternoon, $username!", "Good afternoon, $username!", "Hello, good afternoon to you $username!")
    $eveningGreetings = @("Evening, $username!", "Good evening, $username!", "Hello there, evening is here for you $username!")
    $nightGreetings = @("Nighty-night, $username!", "Sweet dreams, $username!", "Good night $username!, sleep tight, don't let the bedbugs bite!")

    if ($currentTime -ge 6 -and $currentTime -lt 12) {
        $greeting = Get-Random -InputObject $morningGreetings
        Write-Output ("$greeting")
    }
    elseif ($currentTime -ge 12 -and $currentTime -lt 18) {
        $greeting = Get-Random -InputObject $afternoonGreetings
        Write-Output ("$greeting")
    }
    elseif ($currentTime -ge 18 -and $currentTime -lt 22) {
        $greeting = Get-Random -InputObject $eveningGreetings
        Write-Output ("$greeting")
    }
    else {
        $greeting = Get-Random -InputObject $nightGreetings
        Write-Output ("$greeting")
    }
}

# Call the function to get the greeting
Get-Greeting