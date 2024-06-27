<#
#-- Web Request --

$params = @{
    'Uri' = 'http://httpbin.org/post'
    'Method' = 'POST'
    'Headers' = @{'Content-Type' = 'application/json; charset=utf-8'}
}
invoke-webrequest @params

#>
#-- Evil Insult Generator --

$params = @{
    'Uri'         = 'https://evilinsult.com/generate_insult.php?lang=en&type=text'
    'Method'      = 'Post'
    'ContentType' = 'application/json'
}
$Response = invoke-webrequest @params
$Response.Content

# Text
$params = @{
    'Uri'         = 'https://evilinsult.com/generate_insult.php?lang=en&type=json'
    'Method'      = 'Post'
    'ContentType' = 'application/json'
}
$Response = invoke-webrequest @params
($Response | ConvertFrom-Json).insult

# Arabic Text
$params = @{
    'Uri'         = 'https://evilinsult.com/generate_insult.php?lang=ar&type=json'
    'Method'      = 'Post'
    'ContentType' = 'application/json'
}
$Response = invoke-webrequest @params
($Response | ConvertFrom-Json).insult

#-- Simpson's Quotes --

$params = @{
    'Uri'         = 'https://thesimpsonsquoteapi.glitch.me/quotes'
    'Method'      = 'GET'
    'ContentType' = 'application/json'
}
$Response = invoke-webrequest @params
($Response.Content | ConvertFrom-Json).character
($Response.Content | ConvertFrom-Json).quote

#-- Fun Translations --
# Yoda Translator
$Text = "Hello, world!"
$params = @{
    "Uri"         = "https://api.funtranslations.com/translate/yoda.json?text=$text"
    "Method"      = "GET"
    "ContentType" = "application/json"
    'Headers'     = @{'Accept' = 'application/json' }
}
$Response = invoke-webrequest @params
($Response.Content | ConvertFrom-Json).contents.translation
($Response.Content | ConvertFrom-Json).contents.text
($Response.Content | ConvertFrom-Json).contents.translated

# Cockny Translator
$Text = "Hello, world!"
$params = @{
    "Uri"         = "https://api.funtranslations.com/translate/cockney.json?text=$text"
    "Method"      = "GET"
    "ContentType" = "application/json"
    'Headers'     = @{'Accept' = 'application/json' }
}
$Response = invoke-webrequest @params
($Response.Content | ConvertFrom-Json).contents.translation
($Response.Content | ConvertFrom-Json).contents.text
($Response.Content | ConvertFrom-Json).contents.translated

# British Translator
$Text = "Hello, world!"
$params = @{
    "Uri"         = "https://api.funtranslations.com/translate/british.json?text=$text"
    "Method"      = "GET"
    "ContentType" = "application/json"
    'Headers'     = @{'Accept' = 'application/json' }
}
$Response = invoke-webrequest @params
($Response.Content | ConvertFrom-Json).contents.translation
($Response.Content | ConvertFrom-Json).contents.text
($Response.Content | ConvertFrom-Json).contents.translated

# Morse Translator
$Text = "Hello, world!"
$params = @{
    "Uri"         = "https://api.funtranslations.com/translate/morse.json?text=$text"
    "Method"      = "GET"
    "ContentType" = "application/json"
    'Headers'     = @{'Accept' = 'application/json' }
}
$Response = invoke-webrequest @params
($Response.Content | ConvertFrom-Json).contents.translation
($Response.Content | ConvertFrom-Json).contents.text
($Response.Content | ConvertFrom-Json).contents.translated

# shakespeare Translator
$Text = "Hello, world!"
$params = @{
    "Uri"         = "https://api.funtranslations.com/translate/shakespeare.json?text=$text"
    "Method"      = "GET"
    "ContentType" = "application/json"
    'Headers'     = @{'Accept' = 'application/json' }
}
$Response = invoke-webrequest @params
($Response.Content | ConvertFrom-Json).contents.translation
($Response.Content | ConvertFrom-Json).contents.text
($Response.Content | ConvertFrom-Json).contents.translated

# sith Translator
$Text = "Hello, world!"
$params = @{
    "Uri"         = "https://api.funtranslations.com/translate/sith.json?text=$text"
    "Method"      = "GET"
    "ContentType" = "application/json"
    'Headers'     = @{'Accept' = 'application/json' }
}
$Response = invoke-webrequest @params
($Response.Content | ConvertFrom-Json).contents.translation
($Response.Content | ConvertFrom-Json).contents.text
($Response.Content | ConvertFrom-Json).contents.translated

# mandalorian Translator
$Text = "Hello, world!"
$params = @{
    "Uri"         = "https://api.funtranslations.com/translate/mandalorian.json?text=$text"
    "Method"      = "GET"
    "ContentType" = "application/json"
    'Headers'     = @{'Accept' = 'application/json' }
}
$Response = invoke-webrequest @params
($Response.Content | ConvertFrom-Json).contents.translation
($Response.Content | ConvertFrom-Json).contents.text
($Response.Content | ConvertFrom-Json).contents.translated

# fudd Translator
$Text = "Hello, world!"
$params = @{
    "Uri"         = "https://api.funtranslations.com/translate/fudd.json?text=$text"
    "Method"      = "GET"
    "ContentType" = "application/json"
    'Headers'     = @{'Accept' = 'application/json' }
}
$Response = invoke-webrequest @params
($Response.Content | ConvertFrom-Json).contents.translation
($Response.Content | ConvertFrom-Json).contents.text
($Response.Content | ConvertFrom-Json).contents.translated

#-- Random Facts --
# Random Facts
$Uri = "https://uselessfacts.jsph.pl/api/v2/facts/random" # Random Fact
$Uri = "https://uselessfacts.jsph.pl/api/v2/facts/today" # today's fact
$Response = Invoke-WebRequest -Uri $Uri -Method GET -ContentType 'application/json' 
($Response.Content | ConvertFrom-Json).text


# Techy Facts - Text
$params = @{
    "Uri"         = "https://techy-api.vercel.app/api/text"
    "Method"      = "GET"
    "ContentType" = "application/text"
}
$Response = invoke-webrequest @params
$Response.Content

# Techy Facts - json
$params = @{
    "Uri"         = "https://techy-api.vercel.app/api/json"
    "Method"      = "GET"
    "ContentType" = "application/json"
}
$Response = invoke-webrequest @params
($Response.Content | ConvertFrom-Json).message

#-- Jokes --
#  yomomma Jokes
$params = @{
    "Uri"         = "https://beanboi7.github.io/yomomma-apiv2/jokes"
    "Method"      = "GET"
    "ContentType" = "application/json"
}
$Response = invoke-webrequest @params
($Response.Content | ConvertFrom-Json)

#-- Job Board API -- Germany
$params = @{
    "Uri"         = "https://arbeitnow.com/api/job-board-api"
    "Method"      = "GET"
    "ContentType" = "application/json"
}
$Response = invoke-webrequest @params
($Response.Content | ConvertFrom-Json)
($Response.Content | ConvertFrom-Json).data | Select-Object title, company_name, tags, remote, location, url | Where-Object { ($_.tags -match "IT") -and ($_.remote -eq "True") }

#-- Reddit Stock API --
$params = @{
    "Uri"         = "https://tradestie.com/api/v1/apps/reddit"
    "Method"      = "GET"
    "ContentType" = "application/json"
}
$Response = invoke-webrequest @params
($Response.Content | ConvertFrom-Json)

#-- IP Info API --
$ip = "203.205.254.103"
$ip = read-host "Enter IP to get info"
$params = @{
    "Uri"         = "http://ip-api.com/json/$ip"
    "Method"      = "GET"
    "ContentType" = "application/json"
}
$Response = invoke-webrequest @params
Clear-Host
write-host "`nip info details for $ip :" -ForegroundColor Black -BackgroundColor White
($Response.Content | ConvertFrom-Json)

#-- IP Geo API --
#$ip = "203.205.254.103"
$ip = read-host "Enter IP to get info"
$params = @{
    "Uri"         = "https://api.techniknews.net/ipgeo/$ip"
    "Method"      = "GET"
    "ContentType" = "application/json"
}
$Response = invoke-webrequest @params
Clear-Host
write-host "`nipinfo details for $ip :" -ForegroundColor Black -BackgroundColor White
($Response.Content | ConvertFrom-Json)

#-- Dadz Jokes --
$params = @{
    "Uri"         = "https://icanhazdadjoke.com/"
    "Method"      = "GET"
    "ContentType" = "application/json"
    "Headers"     = @{'Accept' = 'application/json' }
}
$Response = invoke-webrequest @params
($Response.Content | ConvertFrom-Json).joke

<#
#-- Web Request --

$params = @{
    'Uri' = 'http://httpbin.org/post'
    'Method' = 'POST'
    'Headers' = @{'Content-Type' = 'application/json; charset=utf-8'; 'Accept' = 'application/json'}
}
invoke-webrequest @params

#>



