#Requires -Version 3.0
<#
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

  Author: Brant Peery
  Senior Software Engineer
  Venafi, Inc
#>

<#
.SYNOPSIS
Creates a new Akamai Session info variable in the Script scope 
.DESCRIPTION
Creates a new Akamai Session info variable for use in the authorization scheme for Akamai web calls made by Invoke-AkamaiRestMethod
.Parameter ClientSecret
The client secret
.Parameter Host
The host address for the api endpoints
.Parameter AccessToken
The access token that will be used to access the API endpoints
.Parameter ClientToken
The client token given when the access token was created
.Parameter Environment
Alias = Section
The environment that the authorization information is used for. Default is 'default'
.Parameter Passthrough
Including this switch will return the session variable instead of set the Script scope session variable
.Parameter EdgeRCJSON
Loads the section and auth info from this file instead of individual parameters. Multiple sections can be included.
Example:
{
    "default":{
        "ClientSecret":"yoursecretgoeshere",
        "Host":"your.specific.host.luna.akamaiapis.net",
        "ClientAccessToken":"your-access-token-here",
        "ClientToken":"your-client-token-here"
    }
}
.EXAMPLE
New-AkamaiSession `
   -ClientSecret 38Vx5gv4BESTyj5nTWrJtK9zAknruJmDWfu74TgAgFg=
   -HostName akab-sadfiud8f9s23d-kjieknsod9e8ns1.luna.akamaiapis.net
   -AccessToken akab-xi6ah7ewe2ae5zbk-doiasdnsdf909da
   -ClientToken akab-opsdkenficn2lm3m-9idnowidmsaoem1
.LINK
developer.akamai.com
#>
Function New-AkamaiSession {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = "Individual")] [string] $ClientSecret,
        [Parameter(Mandatory = $true, ParameterSetName = "Individual")] [string] $HostName,
        [Parameter(Mandatory = $true, ParameterSetName = "Individual")] [string] $ClientAccessToken,
        [Parameter(Mandatory = $true, ParameterSetName = "Individual")] [string] $ClientToken,
        [Parameter(Mandatory = $false, ParameterSetName = "Individual")]
        [Alias("Section")] [string] $Environment = "default",
        [Parameter(Mandatory = $true, ParameterSetName = "json")] [string] $EdgeRCJSON,
        [Parameter()] [switch] $Passthrough
    )
    if (-not ($Script:AkamaiSession) -and $Passthrough.IsPresent -eq $false) {
        $Script:AkamaiSession = [PSCustomObject]@{
            Auth = $null
        }
    }

    if ($EdgeRCJSON) {
        #Use the json string to configure the session
        $AuthInfo = ConvertFrom-Json $EdgeRCJSON

        # Validate auth contents and structure
        if ($null -eq $AuthInfo.PSObject.Properties) {
            throw "Error: At least one config section must be present in the authentication JSON"
        }
        foreach ($p in $AuthInfo.PSObject.Properties) {
            $AuthSection = $p.Value
            if ($null -eq $AuthSection.ClientToken -or $null -eq $AuthSection.ClientAccessToken -or $null -eq $AuthSection.ClientSecret -or $null -eq $AuthSection.Host) {
                throw "Error: Some necessary auth elements missing from the auth section $($p.Name). Please check your EdgeRC JSON"
            }
        }
        #Return the object if passthrough is present. Otherwise set the script variable
        if ($Passthrough.IsPresent) {
            return @{Auth = $AuthInfo }
        }
        else {
            $Script:AkamaiSession.Auth = $authInfo
        }
    }
    else {
        #Use the individually supplied creds and section name
        $newAuth = [PSCustomObject]@{
            ClientToken       = $ClientToken
            ClientAccessToken = $ClientAccessToken
            Host              = $HostName
            ClientSecret      = $ClientSecret
        }
        if ($Passthrough.IsPresent) {
            return [PSCustomObject]@{Auth = [PSCustomObject]@{$Environment = $newAuth } }
        }
        else {
            #If this is the first section, create the Auth object
            if ($Script:AkamaiSession.Auth -eq $null) {
                $Script:AkamaiSession.Auth = [PSCustomObject] @{
                    $Environment = $newAuth
                }
            }
            else {
                #add the environment to the existing Auth object. Force an overwrite if needed
                $Script:AkamaiSession.Auth | Add-Member -MemberType NoteProperty -Name $Environment -Value $newAuth -Force
            }
        }
    }
}
# SIG # Begin signature block
# MIIgEgYJKoZIhvcNAQcCoIIgAzCCH/8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDeKraulw0HHaNv
# bDOOnsEREWg88L07TZw+telXhmm2YqCCDsEwggawMIIEmKADAgECAhAIrUCyYNKc
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
# mKw3mUwz0p7xjQIxghCnMIIQowIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
# Ew5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBD
# b2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTECEAcizMh6w/je5qGZ
# As4SxO0wDQYJYIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
# FTAvBgkqhkiG9w0BCQQxIgQgEigEcxa2a6ucjeMUNMVSgmzWiRzMmbdibgH11c5F
# mTAwDQYJKoZIhvcNAQEBBQAEggIAcnieg75bnYGEUcNBsSKHdFzy9cVO/Zp2gB0i
# FBn3D+luI3OqPzRCNnpOUmkeCpAuXfzXX6ioypEXFg+YQrDN9eIZJ03lAuGGnN0D
# RDnWScUUMS0tNq2e5Jj4pQ//jNmy2kacLPskIdkcZc6/molynolgjmSCOZfJ99IN
# 7Z+k8eg5enNiUtXq3h25FcnjccqhOjuXuZDBuKHLP+/dfokIRufaYdDL1Q5JT7kc
# Ja/cTsQXLgSyMTPWx2J4s1eNlqCtZ3VWgKYMDuG0AjPWZDW8auUwfHiBpvzTQK/i
# HBGFaQ8fEA94WHLgnyhO9FBO6/lLQX4bLQ04rcNagOxN2J0AFXA9Jd2f/PhzT03F
# uP10V0kq+A1xhaWtG6BQWhRWckq/vVhYOVoVKSmi/6tYAWf22uVQh+vju1SDZtRH
# 3JfLe/tWUFSTqIIm7BKvyt6vhRiGUZxdJZKAZu7Hckqg+VEDGa/7OkeorPbM8rWm
# y8XQZwR3Wo/VYhCZZtFi0dtGs27N27oRlOhXW0qkywEZHtp2Yyi1gVX2UxViirMa
# Rpko03TEbXk8uuE3W+p/n2AvFFC4Bl86Fd553trZwmcDIlDRt66QUPejC17joJpB
# A+oRgd5UcxwoGSGUWyfuXf3A+zP1Lt+KyE2WFWLJyi5hN3Tx00UaRx0U23OYruek
# pmHwA6qhgg19MIINeQYKKwYBBAGCNwMDATGCDWkwgg1lBgkqhkiG9w0BBwKggg1W
# MIINUgIBAzEPMA0GCWCGSAFlAwQCAQUAMHcGCyqGSIb3DQEJEAEEoGgEZjBkAgEB
# BglghkgBhv1sBwEwMTANBglghkgBZQMEAgEFAAQg2qH/4fye4+0jjDoD6MlSxQyR
# jHgFWxBN1yAooNIN1qwCEHWyVrJJOEWqjLuioSOSn5IYDzIwMjIwMzIzMTg0OTAx
# WqCCCjcwggT+MIID5qADAgECAhANQkrgvjqI/2BAIc4UAPDdMA0GCSqGSIb3DQEB
# CwUAMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNV
# BAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNz
# dXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0EwHhcNMjEwMTAxMDAwMDAwWhcNMzEwMTA2
# MDAwMDAwWjBIMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4x
# IDAeBgNVBAMTF0RpZ2lDZXJ0IFRpbWVzdGFtcCAyMDIxMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAwuZhhGfFivUNCKRFymNrUdc6EUK9CnV1TZS0DFC1
# JhD+HchvkWsMlucaXEjvROW/m2HNFZFiWrj/ZwucY/02aoH6KfjdK3CF3gIY83ht
# vH35x20JPb5qdofpir34hF0edsnkxnZ2OlPR0dNaNo/Go+EvGzq3YdZz7E5tM4p8
# XUUtS7FQ5kE6N1aG3JMjjfdQJehk5t3Tjy9XtYcg6w6OLNUj2vRNeEbjA4MxKUpc
# DDGKSoyIxfcwWvkUrxVfbENJCf0mI1P2jWPoGqtbsR0wwptpgrTb/FZUvB+hh6u+
# elsKIC9LCcmVp42y+tZji06lchzun3oBc/gZ1v4NSYS9AQIDAQABo4IBuDCCAbQw
# DgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYB
# BQUHAwgwQQYDVR0gBDowODA2BglghkgBhv1sBwEwKTAnBggrBgEFBQcCARYbaHR0
# cDovL3d3dy5kaWdpY2VydC5jb20vQ1BTMB8GA1UdIwQYMBaAFPS24SAd/imu0uRh
# pbKiJbLIFzVuMB0GA1UdDgQWBBQ2RIaOpLqwZr68KC0dRDbd42p6vDBxBgNVHR8E
# ajBoMDKgMKAuhixodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vc2hhMi1hc3N1cmVk
# LXRzLmNybDAyoDCgLoYsaHR0cDovL2NybDQuZGlnaWNlcnQuY29tL3NoYTItYXNz
# dXJlZC10cy5jcmwwgYUGCCsGAQUFBwEBBHkwdzAkBggrBgEFBQcwAYYYaHR0cDov
# L29jc3AuZGlnaWNlcnQuY29tME8GCCsGAQUFBzAChkNodHRwOi8vY2FjZXJ0cy5k
# aWdpY2VydC5jb20vRGlnaUNlcnRTSEEyQXNzdXJlZElEVGltZXN0YW1waW5nQ0Eu
# Y3J0MA0GCSqGSIb3DQEBCwUAA4IBAQBIHNy16ZojvOca5yAOjmdG/UJyUXQKI0ej
# q5LSJcRwWb4UoOUngaVNFBUZB3nw0QTDhtk7vf5EAmZN7WmkD/a4cM9i6PVRSnh5
# Nnont/PnUp+Tp+1DnnvntN1BIon7h6JGA0789P63ZHdjXyNSaYOC+hpT7ZDMjaEX
# cw3082U5cEvznNZ6e9oMvD0y0BvL9WH8dQgAdryBDvjA4VzPxBFy5xtkSdgimnUV
# QvUtMjiB2vRgorq0Uvtc4GEkJU+y38kpqHNDUdq9Y9YfW5v3LhtPEx33Sg1xfpe3
# 9D+E68Hjo0mh+s6nv1bPull2YYlffqe0jmd4+TaY4cso2luHpoovMIIFMTCCBBmg
# AwIBAgIQCqEl1tYyG35B5AXaNpfCFTANBgkqhkiG9w0BAQsFADBlMQswCQYDVQQG
# EwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNl
# cnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcN
# MTYwMTA3MTIwMDAwWhcNMzEwMTA3MTIwMDAwWjByMQswCQYDVQQGEwJVUzEVMBMG
# A1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEw
# LwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgVGltZXN0YW1waW5nIENB
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvdAy7kvNj3/dqbqCmcU5
# VChXtiNKxA4HRTNREH3Q+X1NaH7ntqD0jbOI5Je/YyGQmL8TvFfTw+F+CNZqFAA4
# 9y4eO+7MpvYyWf5fZT/gm+vjRkcGGlV+Cyd+wKL1oODeIj8O/36V+/OjuiI+GKwR
# 5PCZA207hXwJ0+5dyJoLVOOoCXFr4M8iEA91z3FyTgqt30A6XLdR4aF5FMZNJCMw
# XbzsPGBqrC8HzP3w6kfZiFBe/WZuVmEnKYmEUeaC50ZQ/ZQqLKfkdT66mA+Ef58x
# FNat1fJky3seBdCEGXIX8RcG7z3N1k3vBkL9olMqT4UdxB08r8/arBD13ays6Vb/
# kwIDAQABo4IBzjCCAcowHQYDVR0OBBYEFPS24SAd/imu0uRhpbKiJbLIFzVuMB8G
# A1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMBIGA1UdEwEB/wQIMAYBAf8C
# AQAwDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMIMHkGCCsGAQUF
# BwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMG
# CCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRB
# c3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8EejB4MDqgOKA2hjRodHRwOi8vY3Js
# NC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMDqgOKA2
# hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290
# Q0EuY3JsMFAGA1UdIARJMEcwOAYKYIZIAYb9bAACBDAqMCgGCCsGAQUFBwIBFhxo
# dHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BTMAsGCWCGSAGG/WwHATANBgkqhkiG
# 9w0BAQsFAAOCAQEAcZUS6VGHVmnN793afKpjerN4zwY3QITvS4S/ys8DAv3Fp8MO
# IEIsr3fzKx8MIVoqtwU0HWqumfgnoma/Capg33akOpMP+LLR2HwZYuhegiUexLoc
# eywh4tZbLBQ1QwRostt1AuByx5jWPGTlH0gQGF+JOGFNYkYkh2OMkVIsrymJ5Xgf
# 1gsUpYDXEkdws3XVk4WTfraSZ/tTYYmo9WuWwPRYaQ18yAGxuSh1t5ljhSKMYcp5
# lH5Z/IwP42+1ASa2bKXuh1Eh5Fhgm7oMLSttosR+u8QlK0cCCHxJrhO24XxCQijG
# GFbPQTS2Zl22dHv1VjMiLyI2skuiSpXY9aaOUjGCAoYwggKCAgEBMIGGMHIxCzAJ
# BgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5k
# aWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBU
# aW1lc3RhbXBpbmcgQ0ECEA1CSuC+Ooj/YEAhzhQA8N0wDQYJYIZIAWUDBAIBBQCg
# gdEwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0y
# MjAzMjMxODQ5MDFaMCsGCyqGSIb3DQEJEAIMMRwwGjAYMBYEFOHXgqjhkb7va8oW
# kbWqtJSmJJvzMC8GCSqGSIb3DQEJBDEiBCCeDAfJt4mXnf86kNJ+rJ+OkdXcY+TE
# REHl7MC/MgT3LTA3BgsqhkiG9w0BCRACLzEoMCYwJDAiBCCzEJAGvArZgweRVyng
# RANBXIPjKSthTyaWTI01cez1qTANBgkqhkiG9w0BAQEFAASCAQC5uWtUbcL5GHFP
# 5aJAjudkWy+GWRdKcqr5HYsqDGv1AVtBnwKSyy/d4uY9nEfV3o1Kxz0P+YmegO16
# rT+Lc1X0vJVZwkswAnnWXKHwnn0AgtPzYmUDIr5ROsySF7z4BJoLYkYWmlH+mwlg
# QvHkHTCu61bJInis2bQluTbHMA/v8QYtQ1Qn5URaLeF7biE3PSEdVx2zHzpGdz5c
# Z+uZy6cXSLl+OYY9ziFss6fJltVKiUiCDfcW3+0yzqzEOnx9mAWOi5RATznoRMSP
# D086msN0yT1I368OFIFd26k/2Tnyfu/ZvBryksX8mqpddxaeGg0x+0jvvdHFIX5+
# JD7hCNwo
# SIG # End signature block
