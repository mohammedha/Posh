#Requires -Version 5.1
<#
.SYNOPSIS
    Sends a toast message/notification to the currently signed in user.
.DESCRIPTION
    Sends a toast message/notification to the currently signed in user.
    This defaults to using NinjaOne's logo in the Toast Message, but you can specify any png formatted image from a url.
    You can also specify the "ApplicationId" to any string. The default is "NinjaOne RMM".
    Setup Required: Before sending a toast message, this script needs to be ran with just the Setup parameter to prepare the computer.
     This requires running a the SYSTEM user.
    After Setup: Then the Subject and Message parameters can be used to run the script as the currently signed in user.
.EXAMPLE
     -Setup
    Sets up the registry with the default settings needed to send toast messages.
    Defaults:
        ApplicationId = "NinjaOne RMM"
        ImagePath = "C:\Users\Public\PowerShellToastImage.png"
        ImageURL = "http://www.google.com/s2/favicons?sz=128&domain=www.ninjaone.com"
.EXAMPLE
     -Subject "My Subject Here" -Message "My Message Here"
    Sends the subject "My Subject Here" and message "My Message Here" as a Toast message/notification to the currently signed in user.
.EXAMPLE
     -Setup -ApplicationId "MyCompany" -ImageURL "http://www.google.com/s2/favicons?sz=128&domain=www.ninjaone.com" -ImagePath "C:\Users\Public\PowerShellToastImage.png"
    Sets up the registry with the custom setting needed to send toast messages. The example below this is what you will need to use to send the toast message.
.EXAMPLE
     -Subject "My Subject Here" -Message "My Message Here" -ApplicationId "MyCompany"
    Sends the subject "My Subject Here" and message "My Message Here" as a Toast message/notification to the currently signed in user.
        ApplicationId: Creates a registry entry for your toasts called "MyCompany".
        ImageURL: Downloads a png image for the icon in the toast message/notification.
        ImagePath: Where the image will be downloaded to that all users will have access to the image.
.OUTPUTS
    None
.NOTES
    If you want to change the defaults then with in the param block.
    ImagePath uses C:\Users\Public\ as that is accessible by all users.
    If you want to customize the application name to show your company name,
        then look for $ApplicationId and change the content between the double quotes.
    Minimum OS Architecture Supported: Windows 10
    Release Notes:
    Initial Release
By using this script, you indicate your acceptance of the following legal terms as well as our Terms of Use at https://www.ninjaone.com/terms-of-use.
    Ownership Rights: NinjaOne owns and will continue to own all right, title, and interest in and to the script (including the copyright). NinjaOne is giving you a limited license to use the script in accordance with these legal terms. 
    Use Limitation: You may only use the script for your legitimate personal or internal business purposes, and you may not share the script with another party. 
    Republication Prohibition: Under no circumstances are you permitted to re-publish the script in any script library or website belonging to or under the control of any other software provider. 
    Warranty Disclaimer: The script is provided “as is” and “as available”, without warranty of any kind. NinjaOne makes no promise or guarantee that the script will be free from defects or that it will meet your specific needs or expectations. 
    Assumption of Risk: Your use of the script is at your own risk. You acknowledge that there are certain inherent risks in using the script, and you understand and assume each of those risks. 
    Waiver and Release: You will not hold NinjaOne responsible for any adverse or unintended consequences resulting from your use of the script, and you waive any legal or equitable rights or remedies you may have against NinjaOne relating to your use of the script. 
    EULA: If you are a NinjaOne customer, your use of the script is subject to the End User License Agreement applicable to you (EULA).
#>
[CmdletBinding(DefaultParameterSetName = "Default")]
param
(
    [Parameter(Mandatory = $true, ParameterSetName = "Default")]
    [string]
    $Subject,
    [Parameter(Mandatory = $true, ParameterSetName = "Default")]
    [string]
    $Message,
    [Parameter(ParameterSetName = "Setup")]
    [switch]
    $Setup,
    [Parameter(ParameterSetName = "Setup")]
    [string]
    $ImageURL = "http://www.google.com/s2/favicons?sz=128&domain=www.ninjaone.com",
    [Parameter(ParameterSetName = "Setup")]
    [ValidateScript({ Test-Path -Path $_ -IsValid })]
    [string]
    $ImagePath = "C:\Users\Public\PowerShellToastImage.png",
    [Parameter(ParameterSetName = "Setup")]
    [Parameter(ParameterSetName = "Default")]
    [string]
    $ApplicationId = "NinjaOne RMM"
)
begin {
    function Set-ItemProp {
        param (
            $Path,
            $Name,
            $Value,
            [ValidateSet("DWord", "QWord", "String", "ExpandedString", "Binary", "MultiString", "Unknown")]
            $PropertyType = "DWord"
        )
        # Do not output errors and continue
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        if (-not $(Test-Path -Path $Path)) {
            # Check if path does not exist and create the path
            New-Item -Path $Path -Force | Out-Null
        }
        if ((Get-ItemProperty -Path $Path -Name $Name)) {
            # Update property and print out what it was changed from and changed to
            $CurrentValue = Get-ItemProperty -Path $Path -Name $Name
            try {
                Set-ItemProperty -Path $Path -Name $Name -Value $Value -Force -Confirm:$false -ErrorAction Stop | Out-Null
            }
            catch {
                Write-Error $_
            }
            Write-Host "$Path\$Name changed from $($CurrentValue.$Name) to $((Get-ItemProperty -Path $Path -Name $Name).$Name)"
        }
        else {
            # Create property with value
            try {
                New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $PropertyType -Force -Confirm:$false -ErrorAction Stop | Out-Null
            }
            catch {
                Write-Error $_
            }
            Write-Host "Set $Path$Name to $((Get-ItemProperty -Path $Path -Name $Name).$Name)"
        }
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Continue
    }
    function Test-IsElevated {
        $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $p = New-Object System.Security.Principal.WindowsPrincipal($id)
        $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    if ($Setup -and ([System.Security.Principal.WindowsIdentity]::GetCurrent().IsSystem -or $(Test-IsElevated))) {
        Set-ItemProp -Path "HKLM:\SOFTWARE\Classes\AppUserModelId\$($ApplicationId -replace '\s+','.')" -Name "DisplayName" -Value $ApplicationId -PropertyType String
        Invoke-WebRequest -Uri $ImageURL -UseBasicParsing -OutFile $ImagePath
        Set-ItemProp -Path "HKLM:\SOFTWARE\Classes\AppUserModelId\$($ApplicationId -replace '\s+','.')" -Name "IconUri" -Value "$ImagePath" -PropertyType String
    }
    function Show-Notification {
        [CmdletBinding()]
        Param (
            [string]
            $ToastTitle,
            [string]
            [parameter(ValueFromPipeline)]
            $ToastText
        )
        # Import all the needed libraries
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
        [Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
        [Windows.System.User, Windows.System, ContentType = WindowsRuntime] > $null
        [Windows.System.UserType, Windows.System, ContentType = WindowsRuntime] > $null
        [Windows.System.UserAuthenticationStatus, Windows.System, ContentType = WindowsRuntime] > $null
        # Make sure that we can use the toast manager, also checks if the service is running and responding
        try {
            $ToastNotifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($ApplicationId)
        }
        catch {
            Write-Error $_
            Write-Host "Failed to create notification."
        }
        # Use a template for our toast message
        $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastImageAndText02)
        $RawXml = [xml] $Template.GetXml()
        # Edit the template to our liking, in this case just the Title, Message, and path to an image file
        $($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "1" }).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
        $($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "2" }).AppendChild($RawXml.CreateTextNode($ToastText)) > $null
        if ($NodeImg = $RawXml.SelectSingleNode('//image[@id = ''1'']')) {
            $NodeImg.SetAttribute('src', $ImagePath) > $null
        }
        # Serialized Xml for later consumption
        $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $SerializedXml.LoadXml($RawXml.OuterXml)
        # Setup how are toast will act, such as expiration time
        $Toast = $null
        $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
        $Toast.Tag = "PowerShell"
        $Toast.Group = "PowerShell"
        $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)
        # Show our message to the user
        $ToastNotifier.Show($Toast)
    }
}
process {
    # Make sure that Setup was used and that we are running with elevated privileges
    if ($Setup -and ([System.Security.Principal.WindowsIdentity]::GetCurrent().IsSystem -or $(Test-IsElevated))) {
        Write-Host "Used $ImageURL for the default image and saved to $ImagePath"
        Write-Host "ApplicationID: $ApplicationId"
        Write-Host "System is ready to send Toast Messages to the currently logged on user."
        exit 0
    }
    elseif ($Setup -and -not ([System.Security.Principal.WindowsIdentity]::GetCurrent().IsSystem -or $(Test-IsElevated))) {
        Write-Error "Failed to setup registry."
        Write-Host "Please run script as SYSTEM or as a user with administrator privileges."
        exit 1
    }
    try {
        if ($(Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Classes\AppUserModelId\$($ApplicationId -replace '\s+','.')" -Name "DisplayName" -ErrorAction SilentlyContinue) -like $ApplicationId) {
            Show-Notification -ToastTitle $Subject -ToastText $Message -ErrorAction Stop
        }
        else {
            Write-Error "ApplicationId($ApplicationId) was not found in the registry."
            Write-Host "Please run script as an administrator or as the SYSTEM account with the -Setup parameter."
        }
    }
    catch {
        Write-Error $_
        exit 1
    }
    exit 0
}
end {}