function Get-MSStoreAppsWinRT {

    param (
        $Apps, 
        $ExclusionList 
    )

    $PkgMgr = [Windows.Management.Deployment.PackageManager,Windows.Web,ContentType=WindowsRuntime]::new()
    $Pkgs=$PkgMgr.FindPackages()

    foreach($Pkg in $Pkgs)
    {
        #Foreach($Item in $ExclusionList){ If($Pkg -like $Item){ continue } }

        if(-not $Pkg.IsFramework -and -not $Pkg.SignatureKind.Equals("System")) {

            $InstallDate = New-Object System.DateTime(1970, 1, 1)
            if ($null -eq $Pkg.InstalledDate) {
                if(Test-Path -Path $Pkg.InstalledPath) {
                    $InstallDate = [System.IO.File]::GetCreationTime($Pkg.InstalledPath)
                }
            } else {
                $InstallDate = $Pkg.InstalledDate
            }

			# in some cases explict conversion is required, cast will fail
            $Version = New-Object System.Version(
                $pkg.Id.Version.Major,
                $pkg.Id.Version.Minor,
                $pkg.Id.Version.Build,
                $pkg.Id.Version.Revision)

            $VersionString = [System.String]::Format("{0}.{1}.{2}.{3}",
                $pkg.Id.Version.Major,
                $pkg.Id.Version.Minor,
                $pkg.Id.Version.Build,
                $pkg.Id.Version.Revision)

            $Signature = [System.String]$Pkg.SignatureKind

            $App = [PSCustomObject]@{
                Name          = $Pkg.Id.Name
                InstallDate   = $InstallDate.Date.ToString("yyyyMMdd")
				Version       = $Version
                VersionString = $VersionString
                Publisher     = $Pkg.PublisherDisplayName.Replace(",","")
                Location      = $Pkg.InstalledPath
                SignatureKind = [System.String]$Pkg.SignatureKind
            }

		    if($Apps.ContainsKey($App.Name)) {
                if($App.Version -gt $Apps[$App.Name].Version) {
                    $Apps[$App.Name] = $App
                }
		    } else {
			    $Apps[$App.Name]=$App
		    }
        }
    }
}

# Get-AppxPackage returns publisher ID as LDAP DN (distinguished name),
# which is a list of RDNs (relative distinguished names)
function Get-Publisher {
	
    param ( $PublisherID )
    $RDNs = @{}

    $DNTokens = $PublisherID.Split(",")
    foreach($RDNToken in $DNTokens) {
        $NameValueTokens  = $RDNToken.Split("=")
        if($NameValueTokens.Length -eq 2) {
            $RDNs[$NameValueTokens[0].Trim()] = $NameValueTokens[1].Trim()
        }
    }

    if($RDNs.ContainsKey("O")) { #prefer organization if it exists
        return $RDNs["O"]  # O = organization
    }
    elseif($RDNs.ContainsKey("CN")) { #fallback to common name
        return $RDNs["CN"] # CN = common name
    }
	
	return [string]::Empty # publisher not found
}

function Get-MSStoreAppsCmd {
	
    param (
        $Apps, 
        $ExclusionList 
    )

    if (-Not(Get-Command Get-AppxPackage -ErrorAction SilentlyContinue)) {
        throw "Get-AppxPackage command does not exist"
    }
    ## get online provisioned packages
    $Pkgs = Get-AppxPackage -AllUsers | where-object {$_.IsFramework -eq $false}

    foreach($Pkg in $Pkgs)
    {
        #Foreach($Item in $ExclusionList){ If($Pkg -like $Item){ continue } }
        $InstallDate = New-Object System.DateTime(1970, 1, 1)

        if(Test-Path -Path $Pkg.InstallLocation) {
            $InstallDate = [System.IO.File]::GetCreationTime($Pkg.InstallLocation)
        }
        $Version     = New-Object System.Version($Pkg.Version)
		$Publisher   = Get-Publisher $Pkg.Publisher
        
        $App = [PSCustomObject]@{
		    Name          = $Pkg.Name
		    InstallDate   = $InstallDate.Date.ToString("yyyyMMdd")
            Version       = $Version
            VersionString = $Pkg.Version
		    Publisher     = $Publisher
            Location      = $Pkg.InstallLocation
            SignatureKind = $Pkg.SignatureKind
        }
		
		if($Apps.ContainsKey($App.Name)) {
            if($App.Version -gt $Apps[$App.Name].Version) {
                $Apps[$App.Name] = $App
            }
		} else {		
			$Apps[$App.Name] = $App
		}
    }
}

## Exclusion list example
#$ExclusionList = New-Object System.Collections.ArrayList(,@(
#    '*WindowsCalculator*',
#    '*MSPaint*',
#    '*Office.OneNote*',
#    '*Microsoft.net*',
#    '*MicrosoftEdge*'
#))

$Apps = @{}

$Win10RS4 = New-Object Version(10,0,17134,0) # Redstone 4 = W10 1803 = 17134
if([Environment]::OSVersion.Version -ge $Win10RS4) {
    #  Windows.Management C++/WinRT projection metadata: C:\Windows\System32\WinMetadata\Windows.Management.winmd
    $WinMgmtMetadata = [Environment]::GetFolderPath("system") + "\WinMetadata\Windows.Management.winmd"
    if([System.IO.File]::Exists($WinMgmtMetadata)) {
		try {
			# use C++/WinRT projections
			Get-MSStoreAppsWinRT $Apps # prefer COM wrapper if supported
			#Get-MSStoreAppsWinRT -Apps $Apps $ExclusionList
		} catch {
            Write-Error -Message $PSItem.ToString() -ErrorAction Continue
            $Apps.Clear()
			Get-MSStoreAppsCmd $Apps # fallback to cmdlet
            #Get-MSStoreAppsCmd -Apps $Apps $ExclusionList
		}
    }
} else {
    # use PS cmdlet
    Get-MSStoreAppsCmd $Apps
    #Get-MSStoreAppsCmd -Apps $Apps $ExclusionList
}

ForEach($App in $Apps.values){
    # Name,InstallDate,Version,Publisher,UninstallStr,Signature
    "$($App.Name)|$($App.InstallDate)|$($App.VersionString)|$($App.Publisher)|Remove-AppxPackage|$($App.Location)|$($App.SignatureKind)"
}
# SIG # Begin signature block
# MIIq0gYJKoZIhvcNAQcCoIIqwzCCKr8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUiuzz2fgC4YLhwk5T328q7JgU
# cFOggiSOMIIFbzCCBFegAwIBAgIQSPyTtGBVlI02p8mKidaUFjANBgkqhkiG9w0B
# AQwFADB7MQswCQYDVQQGEwJHQjEbMBkGA1UECAwSR3JlYXRlciBNYW5jaGVzdGVy
# MRAwDgYDVQQHDAdTYWxmb3JkMRowGAYDVQQKDBFDb21vZG8gQ0EgTGltaXRlZDEh
# MB8GA1UEAwwYQUFBIENlcnRpZmljYXRlIFNlcnZpY2VzMB4XDTIxMDUyNTAwMDAw
# MFoXDTI4MTIzMTIzNTk1OVowVjELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3Rp
# Z28gTGltaXRlZDEtMCsGA1UEAxMkU2VjdGlnbyBQdWJsaWMgQ29kZSBTaWduaW5n
# IFJvb3QgUjQ2MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAjeeUEiIE
# JHQu/xYjApKKtq42haxH1CORKz7cfeIxoFFvrISR41KKteKW3tCHYySJiv/vEpM7
# fbu2ir29BX8nm2tl06UMabG8STma8W1uquSggyfamg0rUOlLW7O4ZDakfko9qXGr
# YbNzszwLDO/bM1flvjQ345cbXf0fEj2CA3bm+z9m0pQxafptszSswXp43JJQ8mTH
# qi0Eq8Nq6uAvp6fcbtfo/9ohq0C/ue4NnsbZnpnvxt4fqQx2sycgoda6/YDnAdLv
# 64IplXCN/7sVz/7RDzaiLk8ykHRGa0c1E3cFM09jLrgt4b9lpwRrGNhx+swI8m2J
# mRCxrds+LOSqGLDGBwF1Z95t6WNjHjZ/aYm+qkU+blpfj6Fby50whjDoA7NAxg0P
# OM1nqFOI+rgwZfpvx+cdsYN0aT6sxGg7seZnM5q2COCABUhA7vaCZEao9XOwBpXy
# bGWfv1VbHJxXGsd4RnxwqpQbghesh+m2yQ6BHEDWFhcp/FycGCvqRfXvvdVnTyhe
# Be6QTHrnxvTQ/PrNPjJGEyA2igTqt6oHRpwNkzoJZplYXCmjuQymMDg80EY2NXyc
# uu7D1fkKdvp+BRtAypI16dV60bV/AK6pkKrFfwGcELEW/MxuGNxvYv6mUKe4e7id
# FT/+IAx1yCJaE5UZkADpGtXChvHjjuxf9OUCAwEAAaOCARIwggEOMB8GA1UdIwQY
# MBaAFKARCiM+lvEH7OKvKe+CpX/QMKS0MB0GA1UdDgQWBBQy65Ka/zWWSC8oQEJw
# IDaRXBeF5jAOBgNVHQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zATBgNVHSUE
# DDAKBggrBgEFBQcDAzAbBgNVHSAEFDASMAYGBFUdIAAwCAYGZ4EMAQQBMEMGA1Ud
# HwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwuY29tb2RvY2EuY29tL0FBQUNlcnRpZmlj
# YXRlU2VydmljZXMuY3JsMDQGCCsGAQUFBwEBBCgwJjAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuY29tb2RvY2EuY29tMA0GCSqGSIb3DQEBDAUAA4IBAQASv6Hvi3Sa
# mES4aUa1qyQKDKSKZ7g6gb9Fin1SB6iNH04hhTmja14tIIa/ELiueTtTzbT72ES+
# BtlcY2fUQBaHRIZyKtYyFfUSg8L54V0RQGf2QidyxSPiAjgaTCDi2wH3zUZPJqJ8
# ZsBRNraJAlTH/Fj7bADu/pimLpWhDFMpH2/YGaZPnvesCepdgsaLr4CnvYFIUoQx
# 2jLsFeSmTD1sOXPUC4U5IOCFGmjhp0g4qdE2JXfBjRkWxYhMZn0vY86Y6GnfrDyo
# XZ3JHFuu2PMvdM+4fvbXg50RlmKarkUT2n/cR/vfw1Kf5gZV6Z2M8jpiUbzsJA8p
# 1FiAhORFe1rYMIIFjTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG
# 9w0BAQwFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkw
# FwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1
# cmVkIElEIFJvb3QgQ0EwHhcNMjIwODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5WjBi
# MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
# d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3Qg
# RzQwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1KPDAi
# MGkz7MKnJS7JIT3yithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2rsnny
# yhHS5F/WBTxSD1Ifxp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C8weE
# 5nQ7bXHiLQwb7iDVySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBfsXpm
# 7nfISKhmV1efVFiODCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGYQJB5
# w3jHtrHEtWoYOAMQjdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsD
# dV14Ztk6MUSaM0C/CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaYdj1Z
# XUJ2h4mXaXpI8OCiEhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+wJS0
# 0mFt6zPZxd9LBADMfRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hk
# pjPRiQfhvbfmQ6QYuKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+NP8m8
# 00ERElvlEFDrMcXKchYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7FwI+i
# sX4KJpn15GkvmB0t9dmpsh3lGwIDAQABo4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB
# /zAdBgNVHQ4EFgQU7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAUReui
# r/SSy4IxLVGLp6chnfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0w
# azAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUF
# BzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVk
# SURSb290Q0EuY3J0MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAowCDAG
# BgRVHSAAMA0GCSqGSIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9
# mqyhhyzshV6pGrsi+IcaaVQi7aSId229GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxS
# A8hO0Cre+i1Wz/n096wwepqLsl7Uz9FDRJtDIeuWcqFItJnLnU+nBgMTdydE1Od/
# 6Fmo8L8vC6bp8jQ87PcDx4eo0kxAGTVGamlUsLihVo7spNU96LHc/RzY9HdaXFSM
# b++hUD38dglohJ9vytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVrzyerbHbObyMt
# 9H5xaiNrIv8SuFQtJ37YOtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o4rmUMIIF8DCC
# BFigAwIBAgIRAIIxiWPyvkW/fEmkkL71aO0wDQYJKoZIhvcNAQEMBQAwVDELMAkG
# A1UEBhMCR0IxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDErMCkGA1UEAxMiU2Vj
# dGlnbyBQdWJsaWMgQ29kZSBTaWduaW5nIENBIFIzNjAeFw0yMTEwMTEwMDAwMDBa
# Fw0yNDEwMTAyMzU5NTlaMFIxCzAJBgNVBAYTAlVTMRMwEQYDVQQIDApDYWxpZm9y
# bmlhMRYwFAYDVQQKDA1OaW5qYVJNTSwgTExDMRYwFAYDVQQDDA1OaW5qYVJNTSwg
# TExDMIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAy6f6IuTfzK9JHPc4
# OyOzxt6ZPkoxmczQiY/YQbENuLL9KfZT68dSeBczwyBSRYnieIc8LkYbHj7UEVuX
# HVNQAVzwRwYf6W2Zg4ngJPvaV3aHK0k4dNDCOArgWd5sdxsS3JjHiVfOELVH7mZD
# DqEoFjPIwT0BMMOoAXUMF2u7IF+UCuLOYXBpXzlNcX7GQZQ0yoEx7x4Cmwzqqhvd
# aPe9rL0HVhQ7jOYYWrgL6LECb/4q9GahjZTv7I9DPGYf9OR3HA1QsPY5EO4/GhcH
# vrq327BbrCztE23GOQwcxXyUQ4vnB5raXw1xL4L3sq0Wkh0wNHAkpj0yuSwzhkJp
# OTKEXobB2wgAk2Io39JZneaxqLWgi2ySJa0bjCt0NvL6Ha4mQrDsrXdBbaJ1TbMk
# rfmqbjaI82wuAE8u3ccImk5io/VZXBiMomDczudRqCyUJoCEXwTYJ76eSzzY0phK
# Lv/CxV65xXkmXA5bv9pAID9PaNm4YnA3KsG0EYOY/P9Cx3p9AgMBAAGjggG9MIIB
# uTAfBgNVHSMEGDAWgBQPKssghyi47G9IritUpimqF6TNDDAdBgNVHQ4EFgQUDr/9
# OMrDXFmKNY1j6OpYmxmlxuIwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAw
# EwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEoGA1UdIARD
# MEEwNQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2VjdGln
# by5jb20vQ1BTMAgGBmeBDAEEATBJBgNVHR8EQjBAMD6gPKA6hjhodHRwOi8vY3Js
# LnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNDb2RlU2lnbmluZ0NBUjM2LmNybDB5
# BggrBgEFBQcBAQRtMGswRAYIKwYBBQUHMAKGOGh0dHA6Ly9jcnQuc2VjdGlnby5j
# b20vU2VjdGlnb1B1YmxpY0NvZGVTaWduaW5nQ0FSMzYuY3J0MCMGCCsGAQUFBzAB
# hhdodHRwOi8vb2NzcC5zZWN0aWdvLmNvbTAfBgNVHREEGDAWgRRjb3JwX2l0QG5p
# bmphcm1tLmNvbTANBgkqhkiG9w0BAQwFAAOCAYEAWSE+83sdW0kWzZNDtm/WeXyl
# ak1oBuwLVAiXfiBdNuc/kzlcLhGm2urgyjyWZPgECRIvgaeiFpGONh6Yqjf9Cs39
# gyvt3zJw3lwpx2+XjWfqWEJACen7au35B/2tDzQfNmZR2fr0y7PnnEixCsNrBIV3
# 11zm4uWp0yvF/YTzM5ynkfefPsE8zJaUrfLHVLRzvUTXtR3bSK6yOgCoMo89VzpT
# qTXysnbFp96TqzMoEf9ztri/0xt8cXAlHI5J30a2bvVtQDovoStjYViTlgyIfG11
# mXg4CdMtc7oYz350K5LBsExSD2ks9c/TzHEXegzO3b42QS+hOzf9eAJI1WiMCAvJ
# XrrsBKpGY0YdzOkyyAJxx0SUM07zJYfGw/+K5FODWjm802jCrqVl/0Lk7hZZPZ8c
# 07oXtfZwKwAdLi8LsOOF2DDC2BuXIjq9gDwP6/upLTdYnkQX/57cb0q/Ad6UQXJj
# qopYmr+QFqrqGOwOqUI1ZP1m8LKdcui2Fw0C/e4/MIIGGjCCBAKgAwIBAgIQYh1t
# DFIBnjuQeRUgiSEcCjANBgkqhkiG9w0BAQwFADBWMQswCQYDVQQGEwJHQjEYMBYG
# A1UEChMPU2VjdGlnbyBMaW1pdGVkMS0wKwYDVQQDEyRTZWN0aWdvIFB1YmxpYyBD
# b2RlIFNpZ25pbmcgUm9vdCBSNDYwHhcNMjEwMzIyMDAwMDAwWhcNMzYwMzIxMjM1
# OTU5WjBUMQswCQYDVQQGEwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSsw
# KQYDVQQDEyJTZWN0aWdvIFB1YmxpYyBDb2RlIFNpZ25pbmcgQ0EgUjM2MIIBojAN
# BgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAmyudU/o1P45gBkNqwM/1f/bIU1MY
# yM7TbH78WAeVF3llMwsRHgBGRmxDeEDIArCS2VCoVk4Y/8j6stIkmYV5Gej4NgNj
# VQ4BYoDjGMwdjioXan1hlaGFt4Wk9vT0k2oWJMJjL9G//N523hAm4jF4UjrW2pvv
# 9+hdPX8tbbAfI3v0VdJiJPFy/7XwiunD7mBxNtecM6ytIdUlh08T2z7mJEXZD9OW
# cJkZk5wDuf2q52PN43jc4T9OkoXZ0arWZVeffvMr/iiIROSCzKoDmWABDRzV/UiQ
# 5vqsaeFaqQdzFf4ed8peNWh1OaZXnYvZQgWx/SXiJDRSAolRzZEZquE6cbcH747F
# Hncs/Kzcn0Ccv2jrOW+LPmnOyB+tAfiWu01TPhCr9VrkxsHC5qFNxaThTG5j4/Kc
# +ODD2dX/fmBECELcvzUHf9shoFvrn35XGf2RPaNTO2uSZ6n9otv7jElspkfK9qEA
# THZcodp+R4q2OIypxR//YEb3fkDn3UayWW9bAgMBAAGjggFkMIIBYDAfBgNVHSME
# GDAWgBQy65Ka/zWWSC8oQEJwIDaRXBeF5jAdBgNVHQ4EFgQUDyrLIIcouOxvSK4r
# VKYpqhekzQwwDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwGwYDVR0gBBQwEjAGBgRVHSAAMAgGBmeBDAEEATBL
# BgNVHR8ERDBCMECgPqA8hjpodHRwOi8vY3JsLnNlY3RpZ28uY29tL1NlY3RpZ29Q
# dWJsaWNDb2RlU2lnbmluZ1Jvb3RSNDYuY3JsMHsGCCsGAQUFBwEBBG8wbTBGBggr
# BgEFBQcwAoY6aHR0cDovL2NydC5zZWN0aWdvLmNvbS9TZWN0aWdvUHVibGljQ29k
# ZVNpZ25pbmdSb290UjQ2LnA3YzAjBggrBgEFBQcwAYYXaHR0cDovL29jc3Auc2Vj
# dGlnby5jb20wDQYJKoZIhvcNAQEMBQADggIBAAb/guF3YzZue6EVIJsT/wT+mHVE
# YcNWlXHRkT+FoetAQLHI1uBy/YXKZDk8+Y1LoNqHrp22AKMGxQtgCivnDHFyAQ9G
# XTmlk7MjcgQbDCx6mn7yIawsppWkvfPkKaAQsiqaT9DnMWBHVNIabGqgQSGTrQWo
# 43MOfsPynhbz2Hyxf5XWKZpRvr3dMapandPfYgoZ8iDL2OR3sYztgJrbG6VZ9DoT
# XFm1g0Rf97Aaen1l4c+w3DC+IkwFkvjFV3jS49ZSc4lShKK6BrPTJYs4NG1DGzmp
# ToTnwoqZ8fAmi2XlZnuchC4NPSZaPATHvNIzt+z1PHo35D/f7j2pO1S8BCysQDHC
# bM5Mnomnq5aYcKCsdbh0czchOm8bkinLrYrKpii+Tk7pwL7TjRKLXkomm5D1Umds
# ++pip8wH2cQpf93at3VDcOK4N7EwoIJB0kak6pSzEu4I64U6gZs7tS/dGNSljf2O
# SSnRr7KWzq03zl8l75jy+hOds9TWSenLbjBQUGR96cFr6lEUfAIEHVC1L68Y1GGx
# x4/eRI82ut83axHMViw1+sVpbPxg51Tbnio1lB93079WPFnYaOvfGAA0e0zcfF/M
# 9gXr+korwQTh2Prqooq2bYNMvUoUKD85gnJ+t0smrWrb8dee2CvYZXD5laGtaAxO
# fy/VKNmwuWuAh9kcMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkq
# hkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBU
# cnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBj
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMT
# MkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5n
# IENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFV
# xyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8z
# H1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE9
# 8NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iE
# ZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXm
# G6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVV
# JnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz
# +ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8
# ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkr
# qPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKo
# wSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3I
# XjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaA
# FOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAK
# BggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9v
# Y3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4
# oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJv
# b3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqG
# SIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQ
# XeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwI
# gqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs
# 5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAn
# gkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnG
# E4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9
# P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt
# +8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Z
# iza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgx
# tGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimH
# CUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCC
# BsIwggSqoAMCAQICEAVEr/OUnQg5pr/bP1/lYRYwDQYJKoZIhvcNAQELBQAwYzEL
# MAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJE
# aWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBD
# QTAeFw0yMzA3MTQwMDAwMDBaFw0zNDEwMTMyMzU5NTlaMEgxCzAJBgNVBAYTAlVT
# MRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjEgMB4GA1UEAxMXRGlnaUNlcnQgVGlt
# ZXN0YW1wIDIwMjMwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCjU0WH
# HYOOW6w+VLMj4M+f1+XS512hDgncL0ijl3o7Kpxn3GIVWMGpkxGnzaqyat0QKYoe
# YmNp01icNXG/OpfrlFCPHCDqx5o7L5Zm42nnaf5bw9YrIBzBl5S0pVCB8s/LB6Yw
# aMqDQtr8fwkklKSCGtpqutg7yl3eGRiF+0XqDWFsnf5xXsQGmjzwxS55DxtmUuPI
# 1j5f2kPThPXQx/ZILV5FdZZ1/t0QoRuDwbjmUpW1R9d4KTlr4HhZl+NEK0rVlc7v
# CBfqgmRN/yPjyobutKQhZHDr1eWg2mOzLukF7qr2JPUdvJscsrdf3/Dudn0xmWVH
# VZ1KJC+sK5e+n+T9e3M+Mu5SNPvUu+vUoCw0m+PebmQZBzcBkQ8ctVHNqkxmg4ho
# Yru8QRt4GW3k2Q/gWEH72LEs4VGvtK0VBhTqYggT02kefGRNnQ/fztFejKqrUBXJ
# s8q818Q7aESjpTtC/XN97t0K/3k0EH6mXApYTAA+hWl1x4Nk1nXNjxJ2VqUk+tfE
# ayG66B80mC866msBsPf7Kobse1I4qZgJoXGybHGvPrhvltXhEBP+YUcKjP7wtsfV
# x95sJPC/QoLKoHE9nJKTBLRpcCcNT7e1NtHJXwikcKPsCvERLmTgyyIryvEoEyFJ
# UX4GZtM7vvrrkTjYUQfKlLfiUKHzOtOKg8tAewIDAQABo4IBizCCAYcwDgYDVR0P
# AQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgw
# IAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMB8GA1UdIwQYMBaAFLoW
# 2W1NhS9zKXaaL3WMaiCPnshvMB0GA1UdDgQWBBSltu8T5+/N0GSh1VapZTGj3tXj
# STBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGln
# aUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3JsMIGQ
# BggrBgEFBQcBAQSBgzCBgDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNl
# cnQuY29tMFgGCCsGAQUFBzAChkxodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3J0
# MA0GCSqGSIb3DQEBCwUAA4ICAQCBGtbeoKm1mBe8cI1PijxonNgl/8ss5M3qXSKS
# 7IwiAqm4z4Co2efjxe0mgopxLxjdTrbebNfhYJwr7e09SI64a7p8Xb3CYTdoSXej
# 65CqEtcnhfOOHpLawkA4n13IoC4leCWdKgV6hCmYtld5j9smViuw86e9NwzYmHZP
# VrlSwradOKmB521BXIxp0bkrxMZ7z5z6eOKTGnaiaXXTUOREEr4gDZ6pRND45Ul3
# CFohxbTPmJUaVLq5vMFpGbrPFvKDNzRusEEm3d5al08zjdSNd311RaGlWCZqA0Xe
# 2VC1UIyvVr1MxeFGxSjTredDAHDezJieGYkD6tSRN+9NUvPJYCHEVkft2hFLjDLD
# iOZY4rbbPvlfsELWj+MXkdGqwFXjhr+sJyxB0JozSqg21Llyln6XeThIX8rC3D0y
# 33XWNmdaifj2p8flTzU8AL2+nCpseQHc2kTmOt44OwdeOVj0fHMxVaCAEcsUDH6u
# vP6k63llqmjWIso765qCNVcoFstp8jKastLYOrixRoZruhf9xHdsFWyuq69zOuhJ
# RrfVf8y2OMDY7Bz1tqG4QyzfTkx9HmhwwHcK1ALgXGC7KP845VJa1qwXIiNO9OzT
# F/tQa/8Hdx9xl0RBybhG02wyfFgvZ0dl5Rtztpn5aywGRu9BHvDwX+Db2a2QgESv
# gBBBijGCBa4wggWqAgEBMGkwVDELMAkGA1UEBhMCR0IxGDAWBgNVBAoTD1NlY3Rp
# Z28gTGltaXRlZDErMCkGA1UEAxMiU2VjdGlnbyBQdWJsaWMgQ29kZSBTaWduaW5n
# IENBIFIzNgIRAIIxiWPyvkW/fEmkkL71aO0wCQYFKw4DAhoFAKB4MBgGCisGAQQB
# gjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYK
# KwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFIHAIzz8
# req/7Ui7GqB/PVGUmr9JMA0GCSqGSIb3DQEBAQUABIIBgFCe3m4ymbjoLhMwoPDW
# gHAsSPQ9nxmFXgaAzw+To2ww5Mo/CTvBf7Bq4pZ2eR6JQIS5jVg5orpNCvxbFCzd
# wXZhXTn3Oc08JyImeg0zcR7QPNZy0+8911uq9Abs4Umdhl6JnqLG7YimarAokSip
# FIRlkQ1sLHaC7Bo0skZcpXD6A6Y6hLoAfjShk39vHOoESAqGHgrEiYxlF6wNSbrv
# lLK7xuY19N73xtP4xJzU4On44ZPkQHLRH5ogYa9sLmUVJG2ZKdmFTNEJJ3XyEJn5
# gVCHT3Lm+AcoJYVoAsgasTvrS79xhvnVW1HxrcVHnKJgK2X6P/vNFZpVT7HBm0le
# S1f0TpMRJCMN/yu34klPBiPXVL5u+UfUnlFBBTie6AFdUk7aGz+2BXuhs/estcH1
# xi9HzTonelmjzNZ7JCxulkzLu8m70xCoPhJhaDfbytx4iCRqreP1GBmgvrpgE726
# GTjZJwbhx7aYISrK2DyzvSaB7sRXR7L30L0aiCaHWmADOqGCAyAwggMcBgkqhkiG
# 9w0BCQYxggMNMIIDCQIBATB3MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdp
# Q2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2
# IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAVEr/OUnQg5pr/bP1/lYRYwDQYJYIZI
# AWUDBAIBBQCgaTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJ
# BTEPFw0yNDA0MjMxOTE4MjVaMC8GCSqGSIb3DQEJBDEiBCC4+tVpO1iwn9ZGYcLc
# HY9zmjSnBndvV0jP0UNIwoS9gTANBgkqhkiG9w0BAQEFAASCAgCFxUO8lbc8ePkm
# xdf3qvdejOEmKwCTRZdVyJ/lDVt1qdnS3g8MLiOLAm+6yeXNBLTn0wrvuY1WaTQh
# IUGpnfEY7/yciqBQ7eorNNBkvSIiLQq7ZSU3Y3EBF+W/mK3/OkA6Sd0e1cfWacRd
# Rvnw89x2JlZRH6yONjNNukGF48rvXqc6dUCfW8DG7scH2PBDC4VEBzzYijMDfmPp
# M1JHaIsr/mSEXYI609Tmwi7QotN+exnjpAiISGklIhpp+gjDescfqvupZ9P+48jy
# o6CAiwkTo0XeFiWyH28bLjQQUKREv9Utr+kIDJ6VEa08zDc8mn6QMtIfwWLUUqYS
# 3Ejc//sDLyYDM2AwOMyuHij/mUL66SN5ET6BYeznUxbi/b1hSIF7DrjDS26vMuPR
# NZZcFiBaFjEwKzDrODRRmF9wMm82xTy4btT9n8HSoMfQIizu0L3czTAGVALFB34A
# pV7CoqZOluVU0e4QxwQ/mLNsJJ62FR1Yy3Kyurwin6Q2NvSKzhPHxyKlTapQ8FGa
# GyFKIBznU7SwvRTkDMq8f7ARpxNlXvEnUHna6IwkEY7Y1kCqgw7bTo+Yq9m3QR5n
# dff95gS3RMqJCan1o9NdQKOGNZf/bqunC7DAOx36zyQNciy2VH8WT/7Co0RZ2b79
# kGl60oddBp9jFqjpEYFllnE9HTuVRw==
# SIG # End signature block
