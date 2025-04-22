

function New-LegalNotice {
    <#
    .SYNOPSIS
        Installs or Uninstalls the legal notice at logon that is used to prevent users from logging on to a computer that is currently upgrading.
    
    .DESCRIPTION
        Installs or Uninstalls the legal notice at logon that is used to prevent users from logging on to a computer that is currently upgrading.
    
    .PARAMETER Install
        Installs the legal notice at logon.
    
    .PARAMETER Uninstall
        Uninstalls the legal notice at logon.
    
    .EXAMPLE
        New-LegalNotice -Install
        Installs the legal notice at logon.
    
    .EXAMPLE
        New-LegalNotice -Uninstall
        Uninstalls the legal notice at logon.   
    #>
    [CmdletBinding()]
    param (
        [switch]$Install,
        [switch]$Uninstall
    )
    
    begin {
        
    }
    
    process {
        if ($Install) {
            try {
                new-itemproperty -path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -name 'legalnoticecaption' -value "Upgrade in Progress" -PropertyType String -Force -ErrorAction Stop | Out-Null
                new-itemproperty -path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -name 'legalnoticetext' -value "Do NOT log on, computer is currently running Windows OS in-place upgrade." -PropertyType String -Force -ErrorAction Stop | Out-Null
            }
            catch {
                Write-Warning "$($_.Exception.Message)"
            }
        }
        elseif ($Uninstall) {
            try {
                remove-itemproperty -path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -name 'legalnoticecaption' -ErrorAction Stop -Force
                remove-itemproperty -path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -name 'legalnoticetext' -ErrorAction Stop -Force
            }
            catch {
                Write-Warning "$($_.Exception.Message)"
            }
            
        }
    }

    end {
            
    }
}
New-LegalNotice -Install
# New-LegalNotice -Uninstall
