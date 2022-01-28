
#Open URL in default browser Using PowerShell
#The below cmdlet will open "https://debug.to" in your default browser.

Start-Process "https://debug.to"

#Open URL in Microsoft Edge Using PowerShell
#The below cmdlet will open "https://debug.to" in the Microsoft Edge browser.

[system.Diagnostics.Process]::Start("msedge", "https://debug.to")

#Open URL in Google Chrome Using PowerShell
#The below cmdlet will open "https://debug.to" in the Google Chrome browser.

[system.Diagnostics.Process]::Start("chrome", "https://debug.to")

#Open URL in Firefox Using PowerShell
#The below cmdlet will open "https://debug.to" in the Firefox browser.

[system.Diagnostics.Process]::Start("firefox", "https://debug.to")

#Open URL in Internet Explorer Using PowerShell
#The below cmdlet will open "https://debug.to" in the Internet Explorer browser.

[system.Diagnostics.Process]::Start("iexplore", "https://debug.to")

