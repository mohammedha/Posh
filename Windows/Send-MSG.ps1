function Send-MSG {
    <#     
    .SYNOPSIS
    This is a powershell wrapper for MSG.exe, which Send a message to a specified user on a system 
    that is running the messenger service.
    .DESCRIPTION
    The Send-MSG cmdlet sends a message to a specified user on a system
    that is running the messenger service. The messenger service is not
    installed on Windows Server 2012 and newer systems by default.
    .EXAMPLE
    Send-MSG -User * -Message "Test message" 
    Send Message to all users on the local computer.
    .EXAMPLE
    Send-MSG -User * -Message "Test message" -Delay 60
    Send Message to all users on the local computer and wait 60 seconds before sending the message.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = "Identifies the specified username, use * for all users")]
        [Alias("u")]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string]
        $User,
        [Parameter(Mandatory = $true,
            HelpMessage = "Enter the computername to contact.")]
        [Alias("c")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ComputerName,
        [Parameter(Mandatory = $true,
            HelpMessage = "Enter the Message to send.")]
        [Alias("m")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,
        [Parameter(Mandatory = $false,
            Position = 0,
            HelpMessage = "Time delay to wait for receiver to acknowledge message.")]
        [Alias("d")]
        [int]
        $Delay,
        [switch]$wait  
    )
    
    process {
        if ($wait) {
            $arg = "$User /server:$ComputerName /V /W $Message"
        }
        if ($Delay) {
            $arg = "$User /server:$ComputerName /Time:$Delay /V $Message"
        }
        if (!$wait -and !$Delay) {
            $arg = "$User /server:$ComputerName /V $Message"
        }
        # Try to send MSG using $ArgumentList
        try {
            Start-Process msg -ArgumentList $arg -Wait -Verbose
        }
        catch {
            Write-Warning "Failed to send message to $User on $ComputerName"
        }
    }
        
}
