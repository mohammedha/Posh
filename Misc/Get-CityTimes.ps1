function Get-CityTimes {
    # Define an array of city names, their corresponding time zone IDs, and offset from GMT
    $cityTimeZones = @(
        @{ City = "London"; TimeZoneId = "GMT Standard Time"; GMTOffset = 0 },
        @{ City = "Beijing"; TimeZoneId = "China Standard Time"; GMTOffset = 8 },
        @{ City = "Hong Kong"; TimeZoneId = "China Standard Time"; GMTOffset = 8 },
        @{ City = "Shenzhen"; TimeZoneId = "China Standard Time"; GMTOffset = 8 },
        @{ City = "Los Angeles"; TimeZoneId = "Pacific Standard Time"; GMTOffset = -7 },
        @{ City = "New York"; TimeZoneId = "Eastern Standard Time"; GMTOffset = -4 },
        @{ City = "Cairo"; TimeZoneId = "Egypt Standard Time"; GMTOffset = 2 },
        @{ City = "Rome"; TimeZoneId = "W. Europe Standard Time"; GMTOffset = 1 },
        @{ City = "Berlin"; TimeZoneId = "W. Europe Standard Time"; GMTOffset = 1 },
        @{ City = "Tokyo"; TimeZoneId = "Tokyo Standard Time"; GMTOffset = 9 }
    )

    # Get the current UTC time
    $utcTime = [DateTime]::UtcNow

    # Iterate through each city and display its local time with GMT offset
    foreach ($cityTimeZone in $cityTimeZones) {
        try {
            # Get the TimeZoneInfo object for the city
            $timeZone = [TimeZoneInfo]::FindSystemTimeZoneById($cityTimeZone.TimeZoneId)

            # Convert UTC time to the city's local time
            $localTime = [TimeZoneInfo]::ConvertTimeFromUtc($utcTime, $timeZone)

            # Create a custom object to hold the city name, local time, and GMT offset
            $cityObject = [PSCustomObject]@{
                City      = $cityTimeZone.City
                LocalTime = $localTime.ToString("yyyy-MM-dd HH:mm:ss")
                GMTOffset = $cityTimeZone.GMTOffset
            }

            # Output the custom object
            Write-Output $cityObject
        }
        catch {
            Write-Host "Error retrieving time for $($cityTimeZone.City): $_" -ForegroundColor Red
        }
    }
}

# Call the function to display the times
Get-CityTimes