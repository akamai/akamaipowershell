function Deactivate-Property
{
    Param(
        [Parameter(Mandatory=$false)]                                [string]   $PropertyName,
        [Parameter(Mandatory=$false)]                                [string]   $PropertyID,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [string]   $PropertyVersion,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [string]   [ValidateSet('Staging', 'Production')] $Network,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $Note,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]             $NotifyEmails,
        [Parameter(ParameterSetName='postbody', Mandatory=$true)]    [string]   $Body,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [switch]   $AcknowledgeAllWarnings,
        [Parameter(Mandatory=$false)]                                [string]   $GroupID,
        [Parameter(Mandatory=$false)]                                [string]   $ContractId,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   [ValidateSet('NONE', 'OTHER', 'NO_PRODUCTION_TRAFFIC', 'EMERGENCY')] $NoncomplianceReason,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $OtherNoncomplianceReason,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $CustomerEmail,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $PeerReviewdBy,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [switch]   $UnitTested,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string]   $TicketID,
        [Parameter(Mandatory=$false)]                                [string]   $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)]                                [string]   $Section = 'default',
        [Parameter(Mandatory=$false)]                                [string]   $AccountSwitchKey
    )

    if($AcknowledgeAllWarnings){
        Write-Host -ForegroundColor Yellow "WARNING: This parameter is now added by default and is no longer required. It is maintained purely for backwards compatibility and will be removed in a future release"
    }

    if($PropertyName -eq '' -and $PropertyID -eq ''){
        throw 'Either $PropertyName or $PropertyID must be specified'
    }

    # Find property if user has specified PropertyName
    if($PropertyName){
        try{
            $Property = Find-Property -PropertyName $PropertyName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            $PropertyID = $Property.propertyId
            if($PropertyID -eq ''){
                throw "Property '$PropertyName' not found"
            }
        }
        catch{
            throw $_
        }
    }

    if($PropertyVersion.ToLower() -eq "latest"){
        try{
            if($PropertyName){
                $PropertyVersion = $Property.propertyVersion
            }
            else{
                $Property = Get-Property -PropertyID $PropertyID -GroupID $GroupID -ContractId $ContractId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
                $PropertyVersion = $Property.latestVersion
            }
        }
        catch{
            throw $_
        }
    }

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        # Convert NotifyEmails to array if required
        if($NotifyEmails.GetType().Name -eq "String"){
            $NotifyEmails = $NotifyEmails -split ","
        }

        if($NoncomplianceReason -eq 'NONE' -and $Network -eq 'Production'){
            if($CustomerEmail -eq '' -or $PeerReviewdBy -eq '' -or $UnitTested -eq $false){
                throw "You must supply the following when NonComplianceReason is 'NONE': CustomerEmail, PeerReviewedBy & UnitTested"
            }
        }
        
        $BodyObj = @{
            activationType = 'DEACTIVATE'
            propertyVersion = $PropertyVersion;
            network = $Network.ToUpper();
            note = $Note;
            notifyEmails = $NotifyEmails;
            acknowledgeAllWarnings = $true
        }

        # Only add optional fields if they are present

        $ComplianceRecord = @{}
        if($NoncomplianceReason){
            $ComplianceRecord['noncomplianceReason'] = $NoncomplianceReason
        }
        if($CustomerEmail){
            $ComplianceRecord['customerEmail'] = $CustomerEmail
        }
        if($PeerReviewdBy){
            $ComplianceRecord['peerReviewedBy'] = $PeerReviewdBy
        }
        if($UnitTested){
            $ComplianceRecord['unitTested'] = $UnitTested.ToBool()
        }
        if($TicketID){
            $ComplianceRecord['ticketId'] = $TicketID
        }
        if($OtherNoncomplianceReason){
            $ComplianceRecord['otherNoncomplianceReason'] = $OtherNoncomplianceReason
        }

        # Only add compliance record to body if not empty
        if($ComplianceRecord.count -gt 0){
            $BodyObj['complianceRecord'] =  $ComplianceRecord
        }

        $Body = $BodyObj | ConvertTo-Json -Depth 100
    }

    $Path = "/papi/v1/properties/$PropertyID/activations?contractId=$ContractId&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"
    
    try
    {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
        return $Result
    }
    catch
    {
        throw $_
    }
}

# SIG # Begin signature block
# MIIpowYJKoZIhvcNAQcCoIIplDCCKZACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCks2yfA3kGzimB
# P91fAnU1+MMBFDjuz8XhNHbnboMyeqCCDpEwggawMIIEmKADAgECAhAIrUCyYNKc
# TJ9ezam9k67ZMA0GCSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNV
# BAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0z
# NjA0MjgyMzU5NTlaMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQDVtC9C0CiteLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0
# JAfhS0/TeEP0F9ce2vnS1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJr
# Q5qZ8sU7H/Lvy0daE6ZMswEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhF
# LqGfLOEYwhrMxe6TSXBCMo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+F
# LEikVoQ11vkunKoAFdE3/hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh
# 3K3kGKDYwSNHR7OhD26jq22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJ
# wZPt4bRc4G/rJvmM1bL5OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQay
# g9Rc9hUZTO1i4F4z8ujo7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbI
# YViY9XwCFjyDKK05huzUtw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchAp
# QfDVxW0mdmgRQRNYmtwmKwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRro
# OBl8ZhzNeDhFMJlP/2NPTLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IB
# WTCCAVUwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+
# YXsIiGX0TkIwHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0P
# AQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAC
# hjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAED
# MAgGBmeBDAEEATANBgkqhkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql
# +Eg08yy25nRm95RysQDKr2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFF
# UP2cvbaF4HZ+N3HLIvdaqpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1h
# mYFW9snjdufE5BtfQ/g+lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3Ryw
# YFzzDaju4ImhvTnhOE7abrs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5Ubdld
# AhQfQDN8A+KVssIhdXNSy0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw
# 8MzK7/0pNVwfiThV9zeKiwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnP
# LqR0kq3bPKSchh/jwVYbKyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatE
# QOON8BUozu3xGFYHKi8QxAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bn
# KD+sEq6lLyJsQfmCXBVmzGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQji
# WQ1tygVQK+pKHJ6l/aCnHwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbq
# yK+p/pQd52MbOoZWeE4wggfZMIIFwaADAgECAhAJi6B8zycIi8m1Q3xkIZDnMA0G
# CSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjMwMTExMDAwMDAwWhcNMjMwMzAx
# MjM1OTU5WjCB3jETMBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8AgEC
# EwhEZWxhd2FyZTEdMBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEDAOBgNV
# BAUTBzI5MzM2MzcxCzAJBgNVBAYTAlVTMRYwFAYDVQQIEw1NYXNzYWNodXNldHRz
# MRIwEAYDVQQHEwlDYW1icmlkZ2UxIDAeBgNVBAoTF0FrYW1haSBUZWNobm9sb2dp
# ZXMgSW5jMSAwHgYDVQQDExdBa2FtYWkgVGVjaG5vbG9naWVzIEluYzCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBALFDEw1oBMbHbJBtOuHBaSg6zH1hMhdP
# WEtWOgnEO7TgO6LGXoRuP6gZmX844/W6kH+CRIMAzei+6AQ2AUzOAWH7ipwScikJ
# HPmxUWM/+yNWJLrnZtgOtPJalsqm3oTjCF/+WDGEVul5EMhlKb6WIg50gzWr3HbG
# 0ym564cdqZQJtn1k6m13FNtIIykgDuR9ttFdh1tsBBYOrSP6W1uu+NNpDBwr16nj
# SQtmqZTwgO+VZT/dNRvalW1a4vlAgN+U/Xo72aNqIiVnByFP2Gj6IWbUezNjgOFM
# kSe7u52cVu51GfL2XjKWup0X0gfluU06P3QZN+wiZFBfsdmXiGAXPd+UysAGUh1X
# J+2lnVQyHD9L1Qmw11wWD/pNYQIvjWdpzxU5NdaXEH/lbBouF+94C8HI74tyzsSW
# /E9mb+enLAebUp4jemguKMhsZC3WG2PhqlIdvPDWmaGmg6td5flco4W9xUkgf8Lp
# gYrCUaqWwQ/JXht0dl4ITqgJwHorK4MT2B3X0Ft+/cTHLxSBm8TcggwTEPXQHCiZ
# jbxuHNvAZQga7+0NC4cljUhbCbhLTe7gX+XAq9LwcAtlSzN/aVF6tpPMyCj/xuFC
# BjWtML079FoIST69sVfhdjFYUfS1goauFy+CqXda3Rgirv48tm11MmpgJf5uzFy9
# +sdRhWzLC66pAgMBAAGjggIFMIICATAfBgNVHSMEGDAWgBRoN+Drtjv4XxGG+/5h
# ewiIZfROQjAdBgNVHQ4EFgQULvUKZAEQ6oPpuyNAwiZsQgGlULIwDgYDVR0PAQH/
# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMIG1BgNVHR8Ega0wgaowU6BRoE+G
# TWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENvZGVT
# aWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3JsMFOgUaBPhk1odHRwOi8vY3Js
# NC5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JTQTQw
# OTZTSEEzODQyMDIxQ0ExLmNybDA9BgNVHSAENjA0MDIGBWeBDAEDMCkwJwYIKwYB
# BQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCBlAYIKwYBBQUHAQEE
# gYcwgYQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBcBggr
# BgEFBQcwAoZQaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcnQwDAYDVR0T
# AQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAulx9aewYZWl0UyqeAts4V+P06gcL
# f+4Hsnwtn8hAlqT8o+8hnPB5LplZCR3OJT98gIq6dXAvPQJWNq1pc/RD0OTIpEDs
# mqzw0c/OHPrnZcuxQxHojQe2J2Gx9E5u6AobLHFTz1+kmgQzRGyCMBecdPRWubXx
# TyL9SiHE2XN/oXZMBWQdmpl3a79wia495lO2rstz/VNCjX0Hc5FOo+ewExly4WfP
# qYmAVH1cJ3AKrh79dFJhgaeLd/+3szgImHJ8C7EsvobpwKPW9JGbNf6QnvQ/ZbTN
# dqAzedwtAziNw0F26+EKuf2P2VVBIHiepF51Dh+wSo8qA+A9NFxMb17zMXnNx8Xc
# Qd/dAULN3X7XT3J3OaSvxMKTMcboh0r5T3OLTy61KYGBa4UCYuVPrMCv0LjivCdq
# VRfWlZNTrsD0dOIUtpjrK/JLxpwRx0I50QQMsPzs5BJLHS+3ULv82xftwwfMbbLB
# ZicDSmLRN0HVzY0hfxTRwRJAKYmCdhSfH/IcwuKyn4kGeXIkaEtGYAhDvLfyxjXD
# d5VcQeScaq7x+EXW5wgISNwxf2kUFgthzEvDNObsnQ3Lr9TwPy/+5Lkj1Oa5Q2CE
# nALMLhFL55Cz7xHggTSuzdnNLmJPMXj0XwVbDITd0lVjQ9Vn7WNa4U38vn6Xjw+A
# 6gdW445gtFLdy/4xghpoMIIaZAIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
# Ew5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBD
# b2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTECEAmLoHzPJwiLybVD
# fGQhkOcwDQYJYIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
# FTAvBgkqhkiG9w0BCQQxIgQgZOWeLLTmGLgS42ZkBj1TwQQbXvuwN1rRHzANKoNr
# fWMwDQYJKoZIhvcNAQEBBQAEggIAppmaiQrTQOjK4Qo6Rvh9HesZN/zx6Eo6jLLW
# xZlAjmzmna3N7K/FZbF8Tt/0IKkjuJAWVGV4qxW87Br4to8McnXBfv7KE90a4uZg
# ySRQkCwJVyUoaeViqiYNUlluJsNt/gSEWMMkgypzr3Qh43V01OgoCE3D7MEwgE2C
# RP+0VKuRG3nHEUxAjx4GQT0V56KDf7N3hcTySSlMS7CVam4JP15EyVIxc4RZnZvx
# u4e2i0QcBEWwrpo4VfXRJfyA0tBNq2wrZHQaYDKDuyyN87BtavrfVtmFPy//0ggB
# SNNoHm0279Not0HeXtvJOQooyDZdEOQQq6nYCUy6tVzk8C5TiaVO/T3Ss66f+Yds
# IkRD/M3sjfSwhglirPUZ+IvxsGOLROJEKZNo8VyJZQwdFfdTBgnLiyxqvsfDzHgp
# X3S6m9L1KcaW7knxaylLC12/De7RALBcPCwIXgyL2wFLoepKrhvo5NvbUCZuch/z
# xU7GZaB06BvQtXayVu6ksaSp+OFy6jZS7UTAQMyqc+RcgUID1F0mVsBPT/yqTA+M
# orWxvQQmL6xuxZdjTPpcWDb6tquZ+fBOFXrKTc72rmf74l7AEgAV+UBCkz7g6o2/
# HPl02oMxzHdSxVZJUWDmGIlpECAjSVpavOmo3aQ/XcOHw8cflEqyURqUUimqbp/F
# 6FEcfgChghc+MIIXOgYKKwYBBAGCNwMDATGCFyowghcmBgkqhkiG9w0BBwKgghcX
# MIIXEwIBAzEPMA0GCWCGSAFlAwQCAQUAMHgGCyqGSIb3DQEJEAEEoGkEZzBlAgEB
# BglghkgBhv1sBwEwMTANBglghkgBZQMEAgEFAAQgCT1aB1mTjst4np7q8QK7dKfy
# CIxRyFvh37WmZGIhRBkCEQD/gQ5fNa11NmzRwijsZNPmGA8yMDIzMDEyNTE3Mjky
# OFqgghMHMIIGwDCCBKigAwIBAgIQDE1pckuU+jwqSj0pB4A9WjANBgkqhkiG9w0B
# AQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5
# BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0
# YW1waW5nIENBMB4XDTIyMDkyMTAwMDAwMFoXDTMzMTEyMTIzNTk1OVowRjELMAkG
# A1UEBhMCVVMxETAPBgNVBAoTCERpZ2lDZXJ0MSQwIgYDVQQDExtEaWdpQ2VydCBU
# aW1lc3RhbXAgMjAyMiAtIDIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQDP7KUmOsap8mu7jcENmtuh6BSFdDMaJqzQHFUeHjZtvJJVDGH0nQl3PRWWCC9r
# ZKT9BoMW15GSOBwxApb7crGXOlWvM+xhiummKNuQY1y9iVPgOi2Mh0KuJqTku3h4
# uXoW4VbGwLpkU7sqFudQSLuIaQyIxvG+4C99O7HKU41Agx7ny3JJKB5MgB6FVueF
# 7fJhvKo6B332q27lZt3iXPUv7Y3UTZWEaOOAy2p50dIQkUYp6z4m8rSMzUy5Zsi7
# qlA4DeWMlF0ZWr/1e0BubxaompyVR4aFeT4MXmaMGgokvpyq0py2909ueMQoP6Mc
# D1AGN7oI2TWmtR7aeFgdOej4TJEQln5N4d3CraV++C0bH+wrRhijGfY59/XBT3Eu
# iQMRoku7mL/6T+R7Nu8GRORV/zbq5Xwx5/PCUsTmFntafqUlc9vAapkhLWPlWfVN
# L5AfJ7fSqxTlOGaHUQhr+1NDOdBk+lbP4PQK5hRtZHi7mP2Uw3Mh8y/CLiDXgazT
# 8QfU4b3ZXUtuMZQpi+ZBpGWUwFjl5S4pkKa3YWT62SBsGFFguqaBDwklU/G/O+mr
# Bw5qBzliGcnWhX8T2Y15z2LF7OF7ucxnEweawXjtxojIsG4yeccLWYONxu71LHx7
# jstkifGxxLjnU15fVdJ9GSlZA076XepFcxyEftfO4tQ6dwIDAQABo4IBizCCAYcw
# DgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYB
# BQUHAwgwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMB8GA1UdIwQY
# MBaAFLoW2W1NhS9zKXaaL3WMaiCPnshvMB0GA1UdDgQWBBRiit7QYfyPMRTtlwvN
# PSqUFN9SnDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0Eu
# Y3JsMIGQBggrBgEFBQcBAQSBgzCBgDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3Au
# ZGlnaWNlcnQuY29tMFgGCCsGAQUFBzAChkxodHRwOi8vY2FjZXJ0cy5kaWdpY2Vy
# dC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5n
# Q0EuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQBVqioa80bzeFc3MPx140/WhSPx/PmV
# OZsl5vdyipjDd9Rk/BX7NsJJUSx4iGNVCUY5APxp1MqbKfujP8DJAJsTHbCYidx4
# 8s18hc1Tna9i4mFmoxQqRYdKmEIrUPwbtZ4IMAn65C3XCYl5+QnmiM59G7hqopvB
# U2AJ6KO4ndetHxy47JhB8PYOgPvk/9+dEKfrALpfSo8aOlK06r8JSRU1NlmaD1TS
# sht/fl4JrXZUinRtytIFZyt26/+YsiaVOBmIRBTlClmia+ciPkQh0j8cwJvtfEiy
# 2JIMkU88ZpSvXQJT657inuTTH4YBZJwAwuladHUNPeF5iL8cAZfJGSOA1zZaX5YW
# sWMMxkZAO85dNdRZPkOaGK7DycvD+5sTX2q1x+DzBcNZ3ydiK95ByVO5/zQQZ/Ym
# Mph7/lxClIGUgp2sCovGSxVK05iQRWAzgOAj3vgDpPZFR+XOuANCR+hBNnF3rf2i
# 6Jd0Ti7aHh2MWsgemtXC8MYiqE+bvdgcmlHEL5r2X6cnl7qWLoVXwGDneFZ/au/C
# lZpLEQLIgpzJGgV8unG1TnqZbPTontRamMifv427GFxD9dAq6OJi7ngE273R+1sK
# qHB+8JeEeOMIA11HLGOoJTiXAdI/Otrl5fbmm9x+LMz/F0xNAKLY1gEOuIvu5uBy
# VYksJxlh9ncBjDCCBq4wggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZI
# hvcNAQELBQAwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZ
# MBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1
# c3RlZCBSb290IEc0MB4XDTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzEL
# MAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJE
# aWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBD
# QTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVccl
# A8TykTepl1Gh1tKD0Z5Mom2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9Q
# Ewsmc5Zt+FeoAn39Q7SE2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDW
# VtTnKC3r07G1decfBmWNlCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0
# UvJ2R/dhgxndX7RUCyFobjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huo
# wWR0QKfAcsW6Th+xtVhNef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZw
# mCZ/oBpHIEPjQ2OAe3VuJyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rn
# H1pslPJSlRErWHRAKKtzQ87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC
# 3BhIfxQ0z9JMq++bPf4OuGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jz
# RWC8I41Y99xh3pP+OcD5sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEm
# CPkUEBIDfV8ju2TjY+Cm4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4w
# Er1GnrXTdrnSDmuZDNIztM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/
# AgEAMB0GA1UdDgQWBBS6FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs
# 1+OC0nFdZEzfLmc/57qYrhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYI
# KwYBBQUHAwgwdwYIKwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2Nz
# cC5kaWdpY2VydC5jb20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2
# oDSGMmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290
# RzQuY3JsMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG
# 9w0BAQsFAAOCAgEAfVmOwJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3i
# Syn7cIoNqilp/GnBzx0H6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKo
# Fr2pVs8Vc40BIiXOlWk/R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9
# jLxkJodskr2dfNBwCnzvqLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JE
# rpknG6skHibBt94q6/aesXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOA
# CcS2n82HhyS7T6NJuXdmkfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9r
# p/Fmw0HNT7ZAmyEhQNC3EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvE
# lXvtCl8zOYdBeHo46Zzh3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2
# uJPU5vIXmVnKcPA3v5gA3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRi
# CQ8KvYHZE/6/pNHzV9m8BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlH
# K+Z/GqSFD/yYlvZVVCsfgPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwggWN
# MIIEdaADAgECAhAOmxiO+dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJ
# BgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5k
# aWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBD
# QTAeFw0yMjA4MDEwMDAwMDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVT
# MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
# b20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZI
# hvcNAQEBBQADggIPADCCAgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK
# 2FnC4SmnPVirdprNrnsbhA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/G
# nhWlfr6fqVcWWVVyr2iTcMKyunWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJ
# IB1jKS3O7F5OyJP4IWGbNOsFxl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4M
# K7dPpzDZVu7Ke13jrclPXuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN
# 2NQ3pC4FfYj1gj4QkXCrVYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I
# 11pJpMLmqaBn3aQnvKFPObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KIS
# G2aadMreSx7nDmOu5tTvkpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9
# HJXDj/chsrIRt7t/8tWMcCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4
# pncB4Q+UDCEdslQpJYls5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpy
# FiIJ33xMdT9j7CFfxCBRa2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS31
# 2amyHeUbAgMBAAGjggE6MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs
# 1+OC0nFdZEzfLmc/57qYrhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd
# 823IDzAOBgNVHQ8BAf8EBAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzAB
# hhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9j
# YWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQw
# RQYDVR0fBD4wPDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0QXNzdXJlZElEUm9vdENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZI
# hvcNAQEMBQADggEBAHCgv0NcVec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4
# hxppVCLtpIh3bb0aFPQTSnovLbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3
# rDB6mouyXtTP0UNEm0Mh65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs
# 9wPHh6jSTEAZNUZqaVSwuKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K
# 2yCNNWAcAgPLILCsWKAOQGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0n
# ftg62fC2h5b9W9FcrBjDTZ9ztwGpn1eqXijiuZQxggN2MIIDcgIBATB3MGMxCzAJ
# BgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGln
# aUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EC
# EAxNaXJLlPo8Kko9KQeAPVowDQYJYIZIAWUDBAIBBQCggdEwGgYJKoZIhvcNAQkD
# MQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yMzAxMjUxNzI5MjhaMCsG
# CyqGSIb3DQEJEAIMMRwwGjAYMBYEFPOHIk2GM4KSNamUvL2Plun+HHxzMC8GCSqG
# SIb3DQEJBDEiBCDdJt9jM1GYna9c1YE0+DpE3p8hF2zmcI+RrZHGJ10tQjA3Bgsq
# hkiG9w0BCRACLzEoMCYwJDAiBCDH9OG+MiiJIKviJjq+GsT8T+Z4HC1k0EyAdVeg
# I7W2+jANBgkqhkiG9w0BAQEFAASCAgBzr0i9Wl8/fRxKBCgd9YF13FbnmmCt0Z/d
# HbAk5EMcYCfAMBhtneVNrqgRXCZhm+3FfvpuNec9Jk7DDiDn+PFg74SfMf3e89s7
# EnVVYJWgjvqRpl4CJMDGyzHumcmSaIU/biUhLh/GB+7xCWZ7hDL2EETKFqcc7qFN
# Y1PMQPZe1Te2T5X0d54o7icLRIi0w78HE1BF7/OSCN/IS/OV9xNl2hi37boQ4LiD
# N0/tRzVfVOXfUMLor2sQ+Yd17MSKP9BZ8o9Qr+4WGqXhh2ZMsFvAzC424bR00HEg
# 0mN/GHVh44YrDKNI44KqI/oJApyWd5zXbs5Cs40iKicX3UlnWCgLmFLxy5ZE3XYT
# 55hiPVE8kr2neboUgX+uuGKMwmvu449hk6lCnvNumU+juV2Ut0nnfJamT2AwKshb
# PDQ+0Ase0CGrg1XSM8aPUleMG5oEljV68g6Z84vfMHedKWJs/UjtnHO2JucynyPw
# FAdGCyl81wczAUQ7r+S+B/as4skyFMDZaYyAJqOeK4fgtzfcKJK6Otpps4c5Ldkl
# ne54FTeYexHTBEMIEAf36mDfQzH9KHJox7RDZLx+MD06qt54EyH947PLjn1Y/s1+
# df6+QNi8TDUX8Lr7nVcxrsa910fbADr7XZdicGkPgy37IaczaD8FcIN8J1s4fhcb
# KDRzH9RCZA==
# SIG # End signature block
