function New-AppSecCustomDenyAction
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $ConfigName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]    [string] $ConfigID,
        [Parameter(Mandatory=$true)]  [string] $VersionNumber,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]  [object] $CustomDenyAction,
        [Parameter(Mandatory=$false)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        if($ConfigName){
            $Config = List-AppSecConfigurations -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey | where {$_.name -eq $ConfigName}
            if($Config){
                $ConfigID = $Config.id
            }
            else{
                throw("Security config '$ConfigName' not found")
            }
        }
    
        if($VersionNumber.ToLower() -eq 'latest'){
            $VersionNumber = (List-AppSecConfigurationVersions -ConfigID $ConfigID -PageSize 1 -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).version
        }

        if($CustomDenyAction){
            $Body = $CustomDenyAction | ConvertTo-Json -Depth 100
        }
    
        $Path = "/appsec/v1/configs/$ConfigID/versions/$VersionNumber/custom-deny?accountSwitchKey=$AccountSwitchKey"
    
        try {
            $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_ 
        }
    }

    end{}
}
# SIG # Begin signature block
# MIIp2QYJKoZIhvcNAQcCoIIpyjCCKcYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBy5tMm1lTWVrT2
# LeHFl65vI75Tf4ryNy5O0hoWnMP/eaCCDsEwggawMIIEmKADAgECAhAIrUCyYNKc
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
# yK+p/pQd52MbOoZWeE4wgggJMIIF8aADAgECAhAHIszIesP43uahmQLOEsTtMA0G
# CSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjIwMzEwMDAwMDAwWhcNMjMwMzAx
# MjM1OTU5WjCB3jETMBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8AgEC
# EwhEZWxhd2FyZTEdMBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEDAOBgNV
# BAUTBzI5MzM2MzcxCzAJBgNVBAYTAlVTMRYwFAYDVQQIEw1NYXNzYWNodXNldHRz
# MRIwEAYDVQQHEwlDYW1icmlkZ2UxIDAeBgNVBAoTF0FrYW1haSBUZWNobm9sb2dp
# ZXMgSW5jMSAwHgYDVQQDExdBa2FtYWkgVGVjaG5vbG9naWVzIEluYzCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBALiCVhyjVWQnarv6/Pdf97vrz6idrh6v
# hHMOEaB6CxEnjSEn+ukSkOo1Yuq700EIF3zNtOYNssWNMWHkDMv6HRd4SUgWqObR
# UnsxYIcwuiqBZ7lAJ0tnfDv/I4mnSD0WTmOJyMuyBzhQIPErwgDaYZNwKY8z5r8i
# XLa5LVampC97cm69gQMh7xqeXG5xXkTm84lQ0Ub0l2s6GsFR6EP5NbiufFqhbECs
# sedLu0y788juJZwZuxtfTJ7oAmfnrhZ5nzImGfTmvLVsfnztdf5J4wJqiROTtr/x
# 5qDd7zQEnAwMxIH8K75tUclPmfVw/RHCTHBdjBilFajVghSDsFhYB3gN+MFQwPq8
# tXvyCVtv6tMaxtQ5IlDWcVbde1WrM7Y+F0NYUR37kngc1g19+81068Xf5upoFk+s
# k1nL5lR7Ppl2Rx/CbOAktuDXOjPGpamZDfL6BMpHYC0He1FAnn0urIif014E2wlh
# /6C6Lz3Z7cMq3na/uRZs770bHUDzW5iPqKfviO6It44DvNh3jY0cnUzBq5jbzfVY
# u0yyIg2R8CJro3EWnRwViFVvVGTiToUX2DeAoM/eOYtTVDOZNyKC2XscvuoZiT1H
# FO1RJA+aLsv2J8xVHrnRuKXGstJgJce90z9ONa7hw4ZAJiFkiOKfyJ93jYfMnDGr
# 6Ne9/Z2A+Q/lAgMBAAGjggI1MIICMTAfBgNVHSMEGDAWgBRoN+Drtjv4XxGG+/5h
# ewiIZfROQjAdBgNVHQ4EFgQUwv2lfAnAr+YF8AVrOUgJbp0qCEkwLgYDVR0RBCcw
# JaAjBggrBgEFBQcIA6AXMBUME1VTLURFTEFXQVJFLTI5MzM2MzcwDgYDVR0PAQH/
# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMIG1BgNVHR8Ega0wgaowU6BRoE+G
# TWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENvZGVT
# aWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3JsMFOgUaBPhk1odHRwOi8vY3Js
# NC5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JTQTQw
# OTZTSEEzODQyMDIxQ0ExLmNybDA9BgNVHSAENjA0MDIGBWeBDAEDMCkwJwYIKwYB
# BQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCBlAYIKwYBBQUHAQEE
# gYcwgYQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBcBggr
# BgEFBQcwAoZQaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcnQwDAYDVR0T
# AQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEApw9nsvZn9pJnIuDUfGrB4zLqszHo
# 7B4MkNI/mYXHOXSTtan6JMTReBpef1FeGR1k9NLV0gw5brI0OJEcEmvvaisK7o9s
# G0fI5783FyS/sTEnRrsVVie3+h7THYPHNc/2frleWoZ1BgnfQk+ssK42nO2yJGac
# ucuNh4hP5J9HDRY1FRyv+EVu0ez/P/lopbi3FaWF2uON4JWhj9YfHHmvySHCsSOL
# EzKt+f8C2UzhdvTl1k/HPYZ80gD8tkX+7XFDFbZte7t0AELvSS7AAoli1uk1LAtg
# hJcop2m4izJ6iONfc/jVXeswsOORaNcaQA9VcyuVNgxPpXll4W6haBn20IU+86vo
# 6MDJSpisbJvZ7s+0dhyZhy2nrteAFoLATehF2kWinPejeRKy0HV2a1TNaIUh13fu
# yIaNghUdStF+CoGNXe7h2yQX1qmZWnZWZRQumU44Vq1Wew0tgHGSMUAxwioafojX
# QrEa8S8pYG/675jxqjEXwTt5WoCCWDoSfYkku9qANLxkg1f6ZM5v612w8PEdbJpo
# FtwmfLRA57KZ50IcxCk/yUWyFQkvSyupfRurRTjVFDD0OLYr4JdQVpFzZj8z6Quh
# pxbUv+GUtlRIRe4sfyam/VRhblyXMA3Uea8cveWiwjuEDppEPgsIs4G4WBn7RuFV
# mKw3mUwz0p7xjQIxghpuMIIaagIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
# Ew5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBD
# b2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTECEAcizMh6w/je5qGZ
# As4SxO0wDQYJYIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
# FTAvBgkqhkiG9w0BCQQxIgQgvOQQDVn4WPQrD0qjrDzCWc8OBwQZG0cFfJwd9ZDE
# Hi8wDQYJKoZIhvcNAQEBBQAEggIAhZgDu7sr6t5z5gJx9DHHhYHqDADVWpv3VBN1
# /nvyI8R0PK2XXutV/T0upixg0H2Em0e7Cx15jh7dq2IF1nd9qBlFnJj4Ot2tXF1O
# FPOEAgSobwZ7kFrODvDe2GUSIZjxSmDg1ExxmlDkYZX7JrzdoK2eiD6QPxb+IYuP
# OxOuLNEoCOW7GjEWjE/R5LZmmr8ojW2X9icxKs43mtq9Eqh2HlSoBYQNlfibM6Ca
# XwW5D1EThxInRMq/m/weTi/5eXFZa+36A+n3+QFsEAYNjh813iOesapIa+BCVlxB
# zZDNLFZ+1jVIL2jRduXip/GNIoJyBGDReDVrNQGn6yYWODYX72WIMgLrLqWhZ5PQ
# 21xlzI+r7A3qZSMuc+UjAg7ivxwZPaBdyZ0M2qane7KRJEVM+pSMCP9SQamA3gXZ
# XP0o4cnb46T7Ijpq8yuxxPlkWbON7i6AyGGEHH+FiOBUEuwAfPy2aoRBaLKF4bPd
# hNzEH1kwuT/y1BPQg79zEYSU97Cxd0egUUMa36vnjK9A3ztONSNMeBviWp802W/S
# ETPJ6xNjwTWpUHgdZiAm+GJS803rZxKyvCu/c9a+9HttjmwXkbYZDybXpswQwfp3
# J1/lqmW8F/pU1Pc6DgYxIQeGbBJ3OqMDDrNkoNtc+PaTFWynFfeF3iWZP4YbhUKZ
# BQ3AnSahghdEMIIXQAYKKwYBBAGCNwMDATGCFzAwghcsBgkqhkiG9w0BBwKgghcd
# MIIXGQIBAzEPMA0GCWCGSAFlAwQCAQUAMHgGCyqGSIb3DQEJEAEEoGkEZzBlAgEB
# BglghkgBhv1sBwEwMTANBglghkgBZQMEAgEFAAQgkBFJ+BeO3n7muNa5obloGE5h
# +Yrp6TIcy9t6CPRK72sCEQDusWUlx0OXHvtYCIKyV0FLGA8yMDIyMDkxNTE2NTA0
# N1qgghMNMIIGxjCCBK6gAwIBAgIQCnpKiJ7JmUKQBmM4TYaXnTANBgkqhkiG9w0B
# AQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5
# BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0
# YW1waW5nIENBMB4XDTIyMDMyOTAwMDAwMFoXDTMzMDMxNDIzNTk1OVowTDELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSQwIgYDVQQDExtEaWdp
# Q2VydCBUaW1lc3RhbXAgMjAyMiAtIDIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQC5KpYjply8X9ZJ8BWCGPQz7sxcbOPgJS7SMeQ8QK77q8TjeF1+XDbq
# 9SWNQ6OB6zhj+TyIad480jBRDTEHukZu6aNLSOiJQX8Nstb5hPGYPgu/CoQScWyh
# YiYB087DbP2sO37cKhypvTDGFtjavOuy8YPRn80JxblBakVCI0Fa+GDTZSw+fl69
# lqfw/LH09CjPQnkfO8eTB2ho5UQ0Ul8PUN7UWSxEdMAyRxlb4pguj9DKP//GZ888
# k5VOhOl2GJiZERTFKwygM9tNJIXogpThLwPuf4UCyYbh1RgUtwRF8+A4vaK9enGY
# 7BXn/S7s0psAiqwdjTuAaP7QWZgmzuDtrn8oLsKe4AtLyAjRMruD+iM82f/SjLv3
# QyPf58NaBWJ+cCzlK7I9Y+rIroEga0OJyH5fsBrdGb2fdEEKr7mOCdN0oS+wVHbB
# kE+U7IZh/9sRL5IDMM4wt4sPXUSzQx0jUM2R1y+d+/zNscGnxA7E70A+GToC1DGp
# aaBJ+XXhm+ho5GoMj+vksSF7hmdYfn8f6CvkFLIW1oGhytowkGvub3XAsDYmsgg7
# /72+f2wTGN/GbaR5Sa2Lf2GHBWj31HDjQpXonrubS7LitkE956+nGijJrWGwoEEY
# GU7tR5thle0+C2Fa6j56mJJRzT/JROeAiylCcvd5st2E6ifu/n16awIDAQABo4IB
# izCCAYcwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAww
# CgYIKwYBBQUHAwgwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMB8G
# A1UdIwQYMBaAFLoW2W1NhS9zKXaaL3WMaiCPnshvMB0GA1UdDgQWBBSNZLeJIf5W
# WESEYafqbxw2j92vDTBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsMy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1w
# aW5nQ0EuY3JsMIGQBggrBgEFBQcBAQSBgzCBgDAkBggrBgEFBQcwAYYYaHR0cDov
# L29jc3AuZGlnaWNlcnQuY29tMFgGCCsGAQUFBzAChkxodHRwOi8vY2FjZXJ0cy5k
# aWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0
# YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQANLSN0ptH1+OpLmT8B5PYM
# 5K8WndmzjJeCKZxDbwEtqzi1cBG/hBmLP13lhk++kzreKjlaOU7YhFmlvBuYquhs
# 79FIaRk4W8+JOR1wcNlO3yMibNXf9lnLocLqTHbKodyhK5a4m1WpGmt90fUCCU+C
# 1qVziMSYgN/uSZW3s8zFp+4O4e8eOIqf7xHJMUpYtt84fMv6XPfkU79uCnx+196Y
# 1SlliQ+inMBl9AEiZcfqXnSmWzWSUHz0F6aHZE8+RokWYyBry/J70DXjSnBIqbbn
# HWC9BCIVJXAGcqlEO2lHEdPu6cegPk8QuTA25POqaQmoi35komWUEftuMvH1uzit
# zcCTEdUyeEpLNypM81zctoXAu3AwVXjWmP5UbX9xqUgaeN1Gdy4besAzivhKKIwS
# qHPPLfnTI/KeGeANlCig69saUaCVgo4oa6TOnXbeqXOqSGpZQ65f6vgPBkKd3wZo
# lv4qoHRbY2beayy4eKpNcG3wLPEHFX41tOa1DKKZpdcVazUOhdbgLMzgDCS4fFIL
# Hpl878jIxYxYaa+rPeHPzH0VrhS/inHfypex2EfqHIXgRU4SHBQpWMxv03/LvsEO
# Sm8gnK7ZczJZCOctkqEaEf4ymKZdK5fgi9OczG21Da5HYzhHF1tvE9pqEG4fSbdE
# W7QICodaWQR2EaGndwITHDCCBq4wggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlsw
# DQYJKoZIhvcNAQELBQAwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0
# IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNl
# cnQgVHJ1c3RlZCBSb290IEc0MB4XDTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1
# OVowYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYD
# VQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFt
# cGluZyBDQTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9
# cklRVcclA8TykTepl1Gh1tKD0Z5Mom2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+d
# H54PMx9QEwsmc5Zt+FeoAn39Q7SE2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+Qtxn
# jupRPfDWVtTnKC3r07G1decfBmWNlCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9d
# rMvohGS0UvJ2R/dhgxndX7RUCyFobjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02
# DVzV5huowWR0QKfAcsW6Th+xtVhNef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aP
# TnYVVSZwmCZ/oBpHIEPjQ2OAe3VuJyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De
# 4z6ic/rnH1pslPJSlRErWHRAKKtzQ87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPg
# v/CiPMpC3BhIfxQ0z9JMq++bPf4OuGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIs
# VzV5K6jzRWC8I41Y99xh3pP+OcD5sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7
# W4oiqMEmCPkUEBIDfV8ju2TjY+Cm4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTu
# zuldyF4wEr1GnrXTdrnSDmuZDNIztM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8E
# CDAGAQH/AgEAMB0GA1UdDgQWBBS6FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSME
# GDAWgBTs1+OC0nFdZEzfLmc/57qYrhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0l
# BAwwCgYIKwYBBQUHAwgwdwYIKwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8
# MDowOKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0
# ZWRSb290RzQuY3JsMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAN
# BgkqhkiG9w0BAQsFAAOCAgEAfVmOwJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/
# GPvHUF3iSyn7cIoNqilp/GnBzx0H6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBM
# Yh0MCIKoFr2pVs8Vc40BIiXOlWk/R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4s
# nuCKrOX9jLxkJodskr2dfNBwCnzvqLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKj
# I/rAJ4JErpknG6skHibBt94q6/aesXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HB
# anHZxhOACcS2n82HhyS7T6NJuXdmkfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVj
# mScsPT9rp/Fmw0HNT7ZAmyEhQNC3EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87
# eK1MrfvElXvtCl8zOYdBeHo46Zzh3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttv
# FXseGYs2uJPU5vIXmVnKcPA3v5gA3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc6
# 1RWYMbRiCQ8KvYHZE/6/pNHzV9m8BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2
# QqYphwlHK+Z/GqSFD/yYlvZVVCsfgPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3W
# fPwwggWNMIIEdaADAgECAhAOmxiO+dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUA
# MGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsT
# EHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQg
# Um9vdCBDQTAeFw0yMjA4MDEwMDAwMDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNV
# BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
# Y2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqcl
# LskhPfKK2FnC4SmnPVirdprNrnsbhA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YF
# PFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKyunWZanMylNEQRBAu34LzB4TmdDttceIt
# DBvuINXJIB1jKS3O7F5OyJP4IWGbNOsFxl7sWxq868nPzaw0QF+xembud8hIqGZX
# V59UWI4MK7dPpzDZVu7Ke13jrclPXuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1
# ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2Tox
# RJozQL8I11pJpMLmqaBn3aQnvKFPObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdp
# ekjw4KISG2aadMreSx7nDmOu5tTvkpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF
# 30sEAMx9HJXDj/chsrIRt7t/8tWMcCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9
# t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQ
# UOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXk
# aS+YHS312amyHeUbAgMBAAGjggE6MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1Ud
# DgQWBBTs1+OC0nFdZEzfLmc/57qYrhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEt
# UYunpyGd823IDzAOBgNVHQ8BAf8EBAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsG
# AQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0
# dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RD
# QS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAw
# DQYJKoZIhvcNAQEMBQADggEBAHCgv0NcVec4X6CjdBs9thbX979XB72arKGHLOyF
# XqkauyL4hxppVCLtpIh3bb0aFPQTSnovLbc47/T/gLn4offyct4kvFIDyE7QKt76
# LVbP+fT3rDB6mouyXtTP0UNEm0Mh65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8L
# punyNDzs9wPHh6jSTEAZNUZqaVSwuKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2
# CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si
# /xK4VC0nftg62fC2h5b9W9FcrBjDTZ9ztwGpn1eqXijiuZQxggN2MIIDcgIBATB3
# MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UE
# AxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBp
# bmcgQ0ECEAp6SoieyZlCkAZjOE2Gl50wDQYJYIZIAWUDBAIBBQCggdEwGgYJKoZI
# hvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yMjA5MTUxNjUw
# NDdaMCsGCyqGSIb3DQEJEAIMMRwwGjAYMBYEFIUI84ZRXLPTB322tLfAfxtKXkHe
# MC8GCSqGSIb3DQEJBDEiBCDw2My2Rsoi06lyewJ0ajEiZbJ8aj4y9bZwW8bewhVd
# gjA3BgsqhkiG9w0BCRACLzEoMCYwJDAiBCCdppAVw0nGwYl4Rbo1gq1wyI+kKTvb
# ar6cK9JTknnmOzANBgkqhkiG9w0BAQEFAASCAgAJYtjwfHbd9ti+UWwTmiwulMrP
# rcPn/TQrT5SB8vINkS9w9BGyF6P6dUMjKYKOeN4yFIBClNyrHIQv6An58jNHzWMT
# 3NZp68eWbrGSoRUszDexQcLmoSG0jUzSFn7ZpdwYBGKV0px4ja7AXyz6P0dyOqsD
# XUZxprfctXWpzJ1LJC7QONK13qVU/fBPu0ncy/ylqxExalhixKTKBWDIReI++tUB
# VKgaSErXM8OVzBwOs20F5GBqAHnVYcmqVfzSQ+xwWA6XcK7pby7F3AjcqwGRmKXN
# czYRs1Yor9fLAhOu5J4QwC1FOIKmcSV6tuHr/P48OuaJF9iZwEO0KIJl+IbEPHpz
# YPOytpJGUh9Emz1dWX11Z+y2U3BrhFivUMZRmNsYWj5U6tcu4k/ZRhef+Z4XI1RW
# +ZlMIIxYhdUA+PtqfMlckcSV51Lfrbr2a2JKGpXlMZteAs9fkVMofUaIrqbcxXVn
# 6+YEvTEyEkFEbA75JMgzzpn7vg6TKKSDOl0GuJ/f8qffZbfEEAdy+jMn5279ZFUu
# iAFJhjWL9k/dXVIapPVWcJ9hQoxPH4YDb0s5KLj34BQRzaygAQxJLW2c7g3gLWTC
# exqqVHB225AgYF9TE732KM8XYFiJl7V9HvvsdlVu/O8hPvewurgKab7g3WZpcE0d
# 6KXJrhmxmuOGra5IDg==
# SIG # End signature block
