<#
.SYNOPSIS
    This sets the desktop wallpaper for all existing users (if run as System) or the currently logged-in user. To have the wallpaper change take effect immediately please select "Replace Transcoded Wallpaper File" and "Restart Explorer". These options may not work on Windows 7 and Server 2008.
.DESCRIPTION
    This sets the desktop wallpaper for all existing users (if run as System) or the currently logged-in user. 
    To have the wallpaper change take effect immediately please select "Replace Transcoded Wallpaper File" and "Restart Explorer". 
    These options may not work on Windows 7 and Server 2008.
.EXAMPLE
    (No Parameters) - Windows 10
    C:\ProgramData\NinjaRMMAgent\scripting\customscript_gen_55.ps1 : No image given!
    + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
    + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,customscript_gen_55.ps1
    PARAMETER: -Url "https://www.example.com/image.png"
    A link to the wallpaper you would like to set.
    PARAMETER: -Directory "C:\Example\Example"
    A location to store the wallpaper.
.EXAMPLE
    -Url "https://www.microsoft.com/en-us/microsoft-365/blog/wp-content/uploads/sites/2/2021/06/Msft_Nostalgia_Landscape.jpg" -Directory "C:\ProgramData\Wallpaper" (Windows 10 as System)
    
    WARNING: Restarting Explorer.exe is required for wallpaper change to take effect!
    URL Given, Downloading the file...
    Download Attempt 1
    Registry::HKEY_USERS\S-1-5-21-3600085911-33463358-3311494591-1103\Control Panel\Desktop\Wallpaper changed from C:\ProgramData\Wallpaper\wallpaper-686581913.jpg to C:\ProgramData\Wallpaper\wallpaper-1935193304.jpg
    Registry::HKEY_USERS\S-1-5-21-3600085911-33463358-3311494591-1103\Control Panel\Desktop\WallpaperStyle changed from 10 to 10
    Registry::HKEY_USERS\S-1-5-21-3600085911-33463358-3311494591-1103\Control Panel\Desktop\TileWallpaper changed from 0 to 0
    WARNING: Replacing the wallpaper transcoded file is required for wallpaper change to take immediate effect.
    Registry::HKEY_USERS\S-1-5-21-3870645062-3653562310-3850680542-1002\Control Panel\Desktop\Wallpaper changed from C:\ProgramData\Wallpaper\wallpaper-686581913.jpg to C:\ProgramData\Wallpaper\wallpaper-1935193304.jpg
    Registry::HKEY_USERS\S-1-5-21-3870645062-3653562310-3850680542-1002\Control Panel\Desktop\WallpaperStyle changed from 10 to 10
    Registry::HKEY_USERS\S-1-5-21-3870645062-3653562310-3850680542-1002\Control Panel\Desktop\TileWallpaper changed from 0 to 0
    WARNING: Replacing the wallpaper transcoded file is required for wallpaper change to take immediate effect.
    Registry::HKEY_USERS\S-1-5-21-3870645062-3653562310-3850680542-1003\Control Panel\Desktop\Wallpaper changed from C:\ProgramData\Wallpaper\wallpaper-686581913.jpg to C:\ProgramData\Wallpaper\wallpaper-1935193304.jpg
    Registry::HKEY_USERS\S-1-5-21-3870645062-3653562310-3850680542-1003\Control Panel\Desktop\WallpaperStyle changed from 10 to 10
    Registry::HKEY_USERS\S-1-5-21-3870645062-3653562310-3850680542-1003\Control Panel\Desktop\TileWallpaper changed from 0 to 0
    WARNING: Replacing the wallpaper transcoded file is required for wallpaper change to take immediate effect.
    Registry::HKEY_USERS\S-1-5-21-3870645062-3653562310-3850680542-1004\Control Panel\Desktop\Wallpaper changed from C:\ProgramData\Wallpaper\wallpaper-686581913.jpg to C:\ProgramData\Wallpaper\wallpaper-1935193304.jpg
    Registry::HKEY_USERS\S-1-5-21-3870645062-3653562310-3850680542-1004\Control Panel\Desktop\WallpaperStyle changed from 10 to 10
    Registry::HKEY_USERS\S-1-5-21-3870645062-3653562310-3850680542-1004\Control Panel\Desktop\TileWallpaper changed from 0 to 0
    WARNING: Replacing the wallpaper transcoded file is required for wallpaper change to take immediate effect.
PARAMETER: -WallpaperStyle "Fill"
    This will set the wallpaper style to the appropriate option. Valid Options: "Fill", "Fit", "Stretch", "Tile", "Center", "Span"
PARAMETER: -ReplaceTranscodedWallpaperFile
    This will replace the file %APPDATA%\Microsoft\Windows\Themes\TranscodedWallpaper. This file is generated whenever the wallpaper is changed and is required for the wallpaper change to take immediate effect.
PARAMETER: -RestartExplorer
    This will restart explorer.exe. This is required for the wallpaper change to take immediate effect.
.OUTPUTS
    None
.NOTES
    Minimum Supported OS: Windows 7+, Server 2008+
    Release Notes: Initial Release
    By using this script, you indicate your acceptance of the following legal terms as well as our Terms of Use at https://www.ninjaone.com/terms-of-use.
    Ownership Rights: NinjaOne owns and will continue to own all right, title, and interest in and to the script (including the copyright). NinjaOne is giving you a limited license to use the script in accordance with these legal terms. 
    Use Limitation: You may only use the script for your legitimate personal or internal business purposes, and you may not share the script with another party. 
    Republication Prohibition: Under no circumstances are you permitted to re-publish the script in any script library or website belonging to or under the control of any other software provider. 
    Warranty Disclaimer: The script is provided “as is” and “as available”, without warranty of any kind. NinjaOne makes no promise or guarantee that the script will be free from defects or that it will meet your specific needs or expectations. 
    Assumption of Risk: Your use of the script is at your own risk. You acknowledge that there are certain inherent risks in using the script, and you understand and assume each of those risks. 
    Waiver and Release: You will not hold NinjaOne responsible for any adverse or unintended consequences resulting from your use of the script, and you waive any legal or equitable rights or remedies you may have against NinjaOne relating to your use of the script. 
    EULA: If you are a NinjaOne customer, your use of the script is subject to the End User License Agreement applicable to you (EULA).
#>
[CmdletBinding()]
param (
    [Parameter()]
    [String]$Url,
    [Parameter()]
    [String]$Directory,
    [Parameter()]
    [String]$WallpaperStyle = "Fill",
    [Parameter()]
    [Switch]$ReplaceTranscodedWallpaperFile = [System.Convert]::ToBoolean($env:replaceTranscodedWallpaperFile),
    [Parameter()]
    [Switch]$RestartExplorer = [System.Convert]::ToBoolean($env:restartExplorer)
)
begin {
    # Set Dynamic Script Variables (if used)
    if ($env:localWallpaperFile -and $env:localWallpaperFile -notlike "null") { $ExistingImage = $env:localWallpaperFile }
    if ($env:directoryToStoreWallpaperIn -and $env:directoryToStoreWallpaperIn -notlike "null") { $Directory = $env:directoryToStoreWallpaperIn }
    if ($env:linkToWallpaperFile -and $env:linkToWallpaperFile -notlike "null") { $Url = $env:linkToWallpaperFile }
    if ($env:wallpaperDisplayMode -and $env:wallpaperDisplayMode -notlike "null") { $WallpaperStyle = $env:wallpaperDisplayMode }
    # Validate that we received a correct value for the wallpaper style
    $AllowedFit = "Fill", "Fit", "Stretch", "Tile", "Center", "Span"
    if ($AllowedFit -notcontains $WallpaperStyle) {
        Write-Error "[Error] Invalid Wallpaper Display Mode selected. Please use one of the following options. Fill, Fit, Stretch, Tile, Center or Span."
        exit 1
    }
    # If the local file we were told to use doesn't exist we should ignore it.
    if ($ExistingImage -and -not (Test-Path $ExistingImage -ErrorAction SilentlyContinue)) {
        Write-Warning "Existing wallpaper does not exist. Ignoring..."
        $ExistingImage = $Null
    }
    # If we weren't given a link or a local file to use we should error out.
    if (-not ($Url) -and -not ($ExistingImage)) {
        Write-Error "No image given!"
        Exit 1
    }
    # If we don't have a place to store the file and it doesn't already exist we should error out.
    if (-not ($Directory) -and -not ($ExistingImage)) {
        Write-Error "You must specify a location to store the wallpaper."
        Exit 1
    }
    # Create the directory if it does not exist.
    if ($Directory -and -not (Test-Path -Path $Directory -ErrorAction SilentlyContinue)) {
        try {
            New-Item -Path $Directory -ItemType Directory -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Error "Failed to create directory!"
            Exit 1
        }
    }
    # Warn the end-user that the wallpaper change will not take immediate effect.
    if (-not ($RestartExplorer)) {
        Write-Warning "Restarting Explorer.exe is required for wallpaper change to take effect!"
    }
    # Handy download function.
    function Invoke-Download {
        param(
            [Parameter()]
            [String]$URL,
            [Parameter()]
            [String]$BaseName,
            [Parameter()]
            [Switch]$SkipSleep
        )
        Write-Host "URL Given, Downloading the file..."
        $SupportedTLSversions = [enum]::GetValues('Net.SecurityProtocolType')
        if ( ($SupportedTLSversions -contains 'Tls13') -and ($SupportedTLSversions -contains 'Tls12') ) {
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol::Tls13 -bor [System.Net.SecurityProtocolType]::Tls12
        }
        elseif ( $SupportedTLSversions -contains 'Tls12' ) {
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        }
        else {
            # Not everything requires TLS 1.2, but we'll try anyways.
            Write-Warning "TLS 1.2 and or TLS 1.3 isn't supported on this system. This download may fail!"
            if ($PSVersionTable.PSVersion.Major -lt 3) {
                Write-Warning "PowerShell 2 / .NET 2.0 doesn't support TLS 1.2."
            }
        }
        $i = 1
        While ($i -lt 4) {
            if (-not ($SkipSleep)) {
                $SleepTime = Get-Random -Minimum 3 -Maximum 30
                Start-Sleep -Seconds $SleepTime
            }
            Write-Host "Download Attempt $i"
            try {
                $WebClient = New-Object System.Net.WebClient
                $Response = $WebClient.OpenRead($Url)
                $MimeType = $WebClient.ResponseHeaders["Content-Type"]
                $DesiredExtension = switch -regex ($MimeType) {
                    "image/jpeg|image/jpg" { "jpg" }
                    "image/png" { "png" }
                    "image/gif" { "gif" }
                    "image/bmp|image/x-windows-bmp|image/x-bmp" { "bmp" }
                    default { 
                        Write-Error "The URL you provided does not provide a supported image type. Image Types Supported: jpg, jpeg, bmp, png and gif. Image Type detected: $MimeType"
                        Exit 1 
                    }
                }
                $Path = "$BaseName.$DesiredExtension"
                $WebClient.DownloadFile($URL, $Path)
                $File = Test-Path -Path $Path -ErrorAction SilentlyContinue
                $Response.Close()
            }
            catch {
                if ($Response) { $Response.Close() }
                Write-Warning "An error has occured while downloading!"
                Write-Warning $_.Exception.Message
            }
            if ($File) {
                $i = 4
            }
            else {
                $i++
            }
        }
        if (-not (Test-Path $Path)) {
            Write-Error "Failed to download file!"
            Exit 1
        }
        $Path
    }
    # Get a list of all the user profiles for when the script is ran as System.
    function Get-UserHives {
        param (
            [Parameter()]
            [ValidateSet('AzureAD', 'DomainAndLocal', 'All')]
            [String]$Type = "All",
            [Parameter()]
            [String[]]$ExcludedUsers,
            [Parameter()]
            [switch]$IncludeDefault
        )
    
        # User account SID's follow a particular patter depending on if they're Azure AD or a Domain account or a local "workgroup" account.
        $Patterns = switch ($Type) {
            "AzureAD" { "S-1-12-1-(\d+-?){4}$" }
            "DomainAndLocal" { "S-1-5-21-(\d+-?){4}$" }
            "All" { "S-1-12-1-(\d+-?){4}$" ; "S-1-5-21-(\d+-?){4}$" } 
        }
    
        # We'll need the NTuser.dat file to load each users registry hive. So we grab it if their account sid matches the above pattern. 
        $UserProfiles = Foreach ($Pattern in $Patterns) { 
            Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" |
            Where-Object { $_.PSChildName -match $Pattern } | 
            Select-Object @{Name = "SID"; Expression = { $_.PSChildName } },
            @{Name = "UserName"; Expression = { "$($_.ProfileImagePath | Split-Path -Leaf)" } }, 
            @{Name = "UserHive"; Expression = { "$($_.ProfileImagePath)\NTuser.dat" } }, 
            @{Name = "Path"; Expression = { $_.ProfileImagePath } }
        }
    
        # There are some situations where grabbing the .Default user's info is needed.
        switch ($IncludeDefault) {
            $True {
                $DefaultProfile = "" | Select-Object UserName, SID, UserHive, Path
                $DefaultProfile.UserName = "Default"
                $DefaultProfile.SID = "DefaultProfile"
                $DefaultProfile.Userhive = "$env:SystemDrive\Users\Default\NTUSER.DAT"
                $DefaultProfile.Path = "C:\Users\Default"
    
                $DefaultProfile | Where-Object { $ExcludedUsers -notcontains $_.UserName }
            }
        }
    
        $UserProfiles | Where-Object { $ExcludedUsers -notcontains $_.UserName }
    }
    # This makes setting registry keys A LOT easier.
    function Set-HKProperty {
        param (
            $Path,
            $Name,
            $Value,
            [ValidateSet('DWord', 'QWord', 'String', 'ExpandedString', 'Binary', 'MultiString', 'Unknown')]
            $PropertyType = 'DWord'
        )
        if (-not $(Test-Path -Path $Path)) {
            # Check if path does not exist and create the path
            New-Item -Path $Path -Force | Out-Null
        }
        if ((Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue)) {
            # Update property and print out what it was changed from and changed to
            $CurrentValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
            try {
                Set-ItemProperty -Path $Path -Name $Name -Value $Value -Force -Confirm:$false -ErrorAction Stop | Out-Null
            }
            catch {
                Write-Error "[Error] Unable to Set registry key for $Name please see below error!"
                Write-Error $_
                exit 1
            }
            Write-Host "$Path\$Name changed from $CurrentValue to $($(Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name)"
        }
        else {
            # Create property with value
            try {
                New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $PropertyType -Force -Confirm:$false -ErrorAction Stop | Out-Null
            }
            catch {
                Write-Error "[Error] Unable to Set registry key for $Name please see below error!"
                Write-Error $_
                exit 1
            }
            Write-Host "Set $Path\$Name to $($(Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name)"
        }
    }
    # This function was made just so I didn't have to make two versions of what's essentially the same code.
    function Set-WallpaperKeys {
        param(
            $BasePath,
            $WallpaperStyle,
            $ImagePath
        )
        $RegKey = "$BasePath\Control Panel\Desktop"
        $Style = switch ($WallpaperStyle) {
            "Fill" { 10 }
            "Fit" { 6 }
            "Stretch" { 2 }
            "Tile" { 0 }
            "Center" { 0 }
            "Span" { 22 }
        }
        Set-HKProperty -Path $RegKey -Name "Wallpaper" -Value $ImagePath -PropertyType "String"
        Set-HKProperty -Path $RegKey -Name "WallpaperStyle" -Value $Style -PropertyType "String"
        if ($WallpaperStyle -eq "Tile") {
            Set-HKProperty -Path $RegKey -Name "TileWallpaper" -Value 1 -PropertyType "String"
        }
        else {
            Set-HKProperty -Path $RegKey -Name "TileWallpaper" -Value 0 -PropertyType "String"
        }
    }
    # This will overwrite the %APPDATA%\Microsoft\Windows\Themes\TranscodedWallpaper file.
    function Reset-TranscodedWallpaper {
        param(
            $Username,
            $BasePath
        )
        Write-Host "Replacing transcoded wallpaper file for $Username."
        if (-not (Test-Path "$BasePath\Microsoft\Windows\Themes\TranscodedWallpaper" -ErrorAction SilentlyContinue)) {
            Write-Host "Transcoded Wallpaper File does not exist. Creating it..."
            New-Item -ItemType "file" -Path "$BasePath\Microsoft\Windows\Themes" -Name "TranscodedWallpaper" | Out-Null
            # After creating a blank one windows will automatically overwrite it with what's used by the current wallpaper. We'll need to sleep to overwrite it.
            Start-Sleep -Seconds 7
        }
        # If there's more than one file or the file for some reason still does not exist then something fishy is going on.
        $TranscodedWallpaper = Get-ChildItem "$BasePath\Microsoft\Windows\Themes" | Where-Object { $_.Name -eq "TranscodedWallpaper" }
        if (($TranscodedWallpaper | Measure-Object).Count -gt 1) {
            Write-Warning -Message "There is more than 1 Transcoded wallpaper file user $Username may have to Log out and Log back in again to complete the wallpaper update."
        }
        elseif (($TranscodedWallpaper | Measure-Object).Count -lt 1) {
            Write-Warning -Message "Transcoded wallpaper file does not exist. User $Username may have to Log out and Log back in again to complete the wallpaper update."
        }
        else {
            try {
                if (Test-Path $TranscodedWallpaper.FullName -ErrorAction SilentlyContinue) { Get-Item $TranscodedWallpaper.FullName | Remove-Item -Force }
                Copy-Item -Path $ExistingImage -Destination $TranscodedWallpaper.FullName -Force -ErrorAction Stop
            }
            catch {
                Write-Warning -Message "Failed to update Transcoded wallpaper file. User $Username may have to Log out and Log back in again to complete the wallpaper update."
            }
        } 
    }
    # This just restarts explorer.exe
    function Reset-Explorer {
        Write-Host "Restarting Explorer.exe"
        Get-Process explorer | Stop-Process -Force
        Start-Process explorer.exe
    }
    function Test-IsSystem {
        $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        return $id.Name -like "NT AUTHORITY*" -or $id.IsSystem
    }
}
process {
    # If we were given a local file and a link use the local file.
    if ($Url -and -not ($ExistingImage)) {
        
        $ExistingImage = Invoke-Download -Url $Url -BaseName "$Directory\wallpaper-$(Get-Random)"
    }
    
    # Warn that older OS's don't always show the change immediately.
    if ([System.Environment]::OSVersion.Version.Major -lt 10) {
        Write-Warning "On older Operating Systems wallpaper changes may require the user to log out and log back in to take effect."
    }
    if (-not (Test-IsSystem)) {
        # Set's the wallpaper registry keys.
        Set-WallpaperKeys -BasePath "Registry::HKEY_CURRENT_USER" -ImagePath $ExistingImage -WallpaperStyle $WallpaperStyle
        if (-not ($ReplaceTranscodedWallpaperFile)) {
            Write-Warning "Replacing the wallpaper transcoded file is required for wallpaper change to take immediate effect."
            Write-Host ""
            continue
        }
        # Replaces the transcoded wallpaper file.
        Reset-TranscodedWallpaper -Username $env:USERNAME -BasePath $env:APPDATA
        
        if ($RestartExplorer) {
            Reset-Explorer
        }
        exit 0
    }
    Write-Host ""
    $UserProfiles = Get-UserHives -Type "All"
    # Loop through each profile on the machine
    Foreach ($UserProfile in $UserProfiles) {
        # Load User ntuser.dat if it's not already loaded
        If (($ProfileWasLoaded = Test-Path Registry::HKEY_USERS\$($UserProfile.SID)) -eq $false) {
            Start-Process -FilePath "cmd.exe" -ArgumentList "/C reg.exe LOAD HKU\$($UserProfile.SID) `"$($UserProfile.UserHive)`"" -Wait -WindowStyle Hidden
        }
        # Sets the wallpaper registry keys.
        Set-WallpaperKeys -BasePath "Registry::HKEY_USERS\$($UserProfile.SID)" -ImagePath $ExistingImage -WallpaperStyle $WallpaperStyle
        if (-not ($ReplaceTranscodedWallpaperFile)) {
            Write-Warning "Replacing the wallpaper transcoded file is required for wallpaper change to take immediate effect."
            Write-Host ""
            continue
        }
        # Replace the transcoded wallpaper
        Reset-TranscodedWallpaper -Username $UserProfile.UserName -BasePath "$($UserProfile.Path)\AppData\Roaming"
        
        Write-Host ""
        # Unload NTuser.dat
        If ($ProfileWasLoaded -eq $false) {
            [gc]::Collect()
            Start-Sleep 1
            Start-Process -FilePath "cmd.exe" -ArgumentList "/C reg.exe UNLOAD HKU\$($UserProfile.SID)" -Wait -WindowStyle Hidden | Out-Null
        }
    }
    if ($RestartExplorer) {
        Reset-Explorer
    }
    exit 0
}
end {
    
    
    
}