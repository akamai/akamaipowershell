Import-Module $PSScriptRoot/../src/AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:SafeAuthFile = $env:PesterSafeAuthFile
$Script:Section = 'default'
$Script:ClearTextString = 'This is my test string!'
$Script:Base64EncodedString = 'VGhpcyBpcyBteSB0ZXN0IHN0cmluZyE='
$Script:URLEncodedString = 'This%20is%20my%20test%20string!'
$Script:UnsanitizedQuery = 'one=1&two=&three=3&four='
$Script:SanitizedQuery = 'one=1&three=3'
$Script:UnsanitizedFileName = 'This\looks!Kinda<"bad">.txt'
$Script:SanitizedFileName = 'This%5Clooks!Kinda%3C%22bad%22%3E.txt'

Describe 'Safe Shared Tests' {

    BeforeDiscovery {
        
    }

    ### Decode-Base64String
    $Script:Bas64Decode = Decode-Base64String -EncodedString $Base64EncodedString
    it 'Decode-Base64String decodes successfully' {
        $Bas64Decode | Should -Be $ClearTextString
    }

    ### Decode-URL
    $Script:URLDecode = Decode-URL -EncodedString $URLEncodedString
    it 'Decode-URL decodes successfully' {
        $URLDecode | Should -Be $ClearTextString
    }

    ### Get-RandomString - Alphabetical
    $Script:RandomAlphabetical = Get-RandomString -Length 16 -Alphabetical
    it 'Get-RandomString produces alphabetical string' {
        $RandomAlphabetical | Should -Match "[a-z]{16}"
    }

    ### Get-RandomString - AlphaNumeric
    $Script:RandomAlphaNumeric = Get-RandomString -Length 16 -AlphaNumeric
    it 'Get-RandomString produces alphanumeric string' {
        $RandomAlphaNumeric | Should -Match "[a-z0-9]{16}"
    }

    ### Get-RandomString - Numeric
    $Script:RandomNumeric = Get-RandomString -Length 16 -Numeric
    it 'Get-RandomString produces numeric string' {
        $RandomNumeric | Should -Match "[0-9]{16}"
    }

    ### Get-RandomString - Hex
    $Script:RandomHex = Get-RandomString -Length 16 -Hex
    it 'Get-RandomString produces hex string' {
        $RandomHex | Should -Match "[a-f0-9]{16}"
    }

    ### Sanitize-QueryString
    $Script:ParsedQuery = Sanitize-QueryString -QueryString $Script:UnsanitizedQuery
    it 'Sanitize-QueryString strips empty query params' {
        $ParsedQuery | Should -Be $SanitizedQuery
    }

    ### Sanitize-Filename
    $Script:ParsedFileName = Sanitize-FileName -Filename $Script:UnsanitizedFileName
    it 'Sanitize-Filename encodes invalid characters' {
        $ParsedFileName | Should -Be $SanitizedFilename
    }

    ### Test-OpenAPI
    $Script:APIResult = Test-OpenAPI -Path '/papi/v1/contracts' -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Test-OpenAPI returns data successfully' {
        $APIResult.count | Should -Not -Be 0
    }

    ### Verify-Auth
    $Script:Auth = Verify-Auth -ReturnObject -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Verify-Auth returns an object' {
        $Auth.scope | Should -Not -BeNullOrEmpty
    }

    ### Get-AkamaiCredentials from edgerc
    it 'Get-AkamaiCredentials from edgercFile parses correctly' {
        $Script:Auth = Get-AkamaiCredentials -EdgeRCFile $SafeEdgeRCFile -Section $Section
        $Auth.client_token | Should -Not -BeNullOrEmpty
        $Auth.access_token | Should -Not -BeNullOrEmpty
        $Auth.client_secret | Should -Not -BeNullOrEmpty
        $Auth.host | Should -Not -BeNullOrEmpty
    }

    ### Get-AkamaiCredentials from environment, default section
    it 'Get-AkamaiCredentials from default environment parses correctly' {
        $env:AKAMAI_HOST = 'env-host'
        $env:AKAMAI_CLIENT_TOKEN = 'env-client_token'
        $env:AKAMAI_ACCESS_TOKEN = 'env-access_token'
        $env:AKAMAI_CLIENT_SECRET = 'env-client_secret'
        $Script:DefaultEnvAuth = Get-AkamaiCredentials
        $DefaultEnvAuth.client_token | Should -Be 'env-client_token'
        $DefaultEnvAuth.access_token | Should -Be 'env-access_token'
        $DefaultEnvAuth.client_secret | Should -Be 'env-client_secret'
        $DefaultEnvAuth.host | Should -Be 'env-host'
    }

    ### Get-AkamaiCredentials from environment, custom section
    it 'Get-AkamaiCredentials from custom environment parses correctly' {
        $env:AKAMAI_CUSTOM_HOST = 'customenv-host'
        $env:AKAMAI_CUSTOM_CLIENT_TOKEN = 'customenv-client_token'
        $env:AKAMAI_CUSTOM_ACCESS_TOKEN = 'customenv-access_token'
        $env:AKAMAI_CUSTOM_CLIENT_SECRET = 'customenv-client_secret'
        $Script:CustomEnvAuth = Get-AkamaiCredentials -Section Custom
        $CustomEnvAuth.client_token | Should -Be 'customenv-client_token'
        $CustomEnvAuth.access_token | Should -Be 'customenv-access_token'
        $CustomEnvAuth.client_secret | Should -Be 'customenv-client_secret'
        $CustomEnvAuth.host | Should -Be 'customenv-host'
    }

    ### Get-AkamaiCredentials from session
    it 'Get-AkamaiCredentials from session parses correctly' {
        New-AkamaiSession -ClientSecret 'session-client_secret' -HostName 'session-host' -ClientAccessToken 'session-access_token' -ClientToken 'session-client_token'
        $Script:SessionAuth = Get-AkamaiCredentials
        $SessionAuth.client_token | Should -Be 'session-client_token'
        $SessionAuth.access_token | Should -Be 'session-access_token'
        $SessionAuth.client_secret | Should -Be 'session-client_secret'
        $SessionAuth.host | Should -Be 'session-host'
    }

    ### Get-NetstorageCredentials from file
    $Script:NSAuth = Get-NetstorageCredentials -AuthFile $SafeAuthFile -Section $Section
    it 'Get-NetstorageCredentials from file parses correctly' {
        $NSAuth.cpcode | Should -Not -BeNullOrEmpty
        $NSAuth.group | Should -Not -BeNullOrEmpty
        $NSAuth.key | Should -Not -BeNullOrEmpty
        $NSAuth.id | Should -Not -BeNullOrEmpty
        $NSAuth.host | Should -Not -BeNullOrEmpty
    }

    ### Get-NetstorageCredentials from default environment
    it 'Get-NetstorageCredentials from default environment parses correctly' {
        $env:NETSTORAGE_CPCODE = 'env-cpcode'
        $env:NETSTORAGE_GROUP = 'env-group'
        $env:NETSTORAGE_KEY = 'env-key'
        $env:NETSTORAGE_ID = 'env-id'
        $env:NETSTORAGE_HOST = 'env-host'
        $Script:DefaultEnvNSAuth = Get-NetstorageCredentials
        $DefaultEnvNSAuth.cpcode | Should -Be 'env-cpcode'
        $DefaultEnvNSAuth.group | Should -Be 'env-group'
        $DefaultEnvNSAuth.key | Should -Be 'env-key'
        $DefaultEnvNSAuth.id | Should -Be 'env-id'
        $DefaultEnvNSAuth.host | Should -Be 'env-host'
    }

    ### Get-NetstorageCredentials from custom environment
    it 'Get-NetstorageCredentials from custom environment parses correctly' {
        $env:NETSTORAGE_CUSTOM_CPCODE = 'customenv-cpcode'
        $env:NETSTORAGE_CUSTOM_GROUP = 'customenv-group'
        $env:NETSTORAGE_CUSTOM_KEY = 'customenv-key'
        $env:NETSTORAGE_CUSTOM_ID = 'customenv-id'
        $env:NETSTORAGE_CUSTOM_HOST = 'customenv-host'
        $Script:CustomEnvNSAuth = Get-NetstorageCredentials -Section Custom
        $CustomEnvNSAuth.cpcode | Should -Be 'customenv-cpcode'
        $CustomEnvNSAuth.group | Should -Be 'customenv-group'
        $CustomEnvNSAuth.key | Should -Be 'customenv-key'
        $CustomEnvNSAuth.id | Should -Be 'customenv-id'
        $CustomEnvNSAuth.host | Should -Be 'customenv-host'
    }

    ### Remove-AkamaiSession
    it 'Remove-AkamaiSession should not throw an error' {
        { Remove-AkamaiSession } | Should -Not -Throw
    }

    AfterAll {
        ## Clean up env variables
        Remove-Item -Path env:\AKAMAI_HOST
        Remove-Item -Path env:\AKAMAI_CLIENT_TOKEN
        Remove-Item -Path env:\AKAMAI_ACCESS_TOKEN
        Remove-Item -Path env:\AKAMAI_CLIENT_SECRET
        Remove-Item -Path env:\AKAMAI_CUSTOM_HOST
        Remove-Item -Path env:\AKAMAI_CUSTOM_CLIENT_TOKEN
        Remove-Item -Path env:\AKAMAI_CUSTOM_ACCESS_TOKEN
        Remove-Item -Path env:\AKAMAI_CUSTOM_CLIENT_SECRET
        Remove-Item -Path env:\NETSTORAGE_CPCODE
        Remove-Item -Path env:\NETSTORAGE_GROUP
        Remove-Item -Path env:\NETSTORAGE_KEY
        Remove-Item -Path env:\NETSTORAGE_ID
        Remove-Item -Path env:\NETSTORAGE_HOST
    }
    
}

Describe 'Unsafe Shared Tests' {
    
}

# SIG # Begin signature block
# MIIpogYJKoZIhvcNAQcCoIIpkzCCKY8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCD5AHw/DZwF37Lf
# hSZ8sWJ/pdeFGRmL03qbQlJJfvoN2qCCDo4wggawMIIEmKADAgECAhAIrUCyYNKc
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
# yK+p/pQd52MbOoZWeE4wggfWMIIFvqADAgECAhAByZH9J50Asj/oHHbeHclzMA0G
# CSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjMwNjEzMDAwMDAwWhcNMjQwMzAy
# MjM1OTU5WjCB3jETMBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8AgEC
# EwhEZWxhd2FyZTEdMBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEDAOBgNV
# BAUTBzI5MzM2MzcxCzAJBgNVBAYTAlVTMRYwFAYDVQQIEw1NYXNzYWNodXNldHRz
# MRIwEAYDVQQHEwlDYW1icmlkZ2UxIDAeBgNVBAoTF0FrYW1haSBUZWNobm9sb2dp
# ZXMgSW5jMSAwHgYDVQQDExdBa2FtYWkgVGVjaG5vbG9naWVzIEluYzCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBANdcrYnd5Y2q/LVByT4/w8A8XsvNZyET
# aJPcPw3DKpswy7TCGFLdVd5sD923zWlXy5VmXqYB/QQ1+yPjgSdgxiOFuhxL8tll
# 8OSb6auUUyrnIXx4PbcDAOKfd9J0IkQuBGNZvnMom9DkxTEpunaLEqjVFo08i53H
# 4VNmPgr7//qbEBCCulDYAg6K6HV7vckP/dTwqJ17jP3Qw0N8rnjcoxf6AwuuKcxl
# lQ4Zdr9q1yYUkvuAw6I5Vw78ODwb1Q+/nK+rYMY+Lx4W7YeAsvAXKWlUE5AXLgVC
# 3N7Xa5ZtAsaLzXJIcqW3HhCEWTygP0lTaPN9CIMnQqLtbve1PVaHH4bXG8hV9kuR
# hT5ZjvVGPDAJ9+xZap9AV+oVNp7QcbQ/p4r104TDGMA2j1wGUmRBcZobo2ypOREd
# jaI4xymenRenRhnxuAdU6Vm3yYam6XiWrIJszEk0i23bFs6wDy5wSPqr11lxn3Zh
# ksb04q+UvU+IhNkStSfwS5wizLA/KSuUjBkU7+sEd5lJaFEHHj3sH192ajODOi4s
# 3empeuwFjZbWukcq8fTLHiTkhyPoPgjvYq+6l0pZdH48pZA6utqMDO/0xIHl+PAy
# oQDVZgufYvvzsAGGF7cyFRyS7F/Tprxbd11w8DNv9I0MR+1zCMRPldAQ4aMYEakI
# kSHYuPZjXWVnAgMBAAGjggICMIIB/jAfBgNVHSMEGDAWgBRoN+Drtjv4XxGG+/5h
# ewiIZfROQjAdBgNVHQ4EFgQU4lrKPnD2cLwdOGv6x3R0iO+5q64wDgYDVR0PAQH/
# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMIG1BgNVHR8Ega0wgaowU6BRoE+G
# TWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENvZGVT
# aWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3JsMFOgUaBPhk1odHRwOi8vY3Js
# NC5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JTQTQw
# OTZTSEEzODQyMDIxQ0ExLmNybDA9BgNVHSAENjA0MDIGBWeBDAEDMCkwJwYIKwYB
# BQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCBlAYIKwYBBQUHAQEE
# gYcwgYQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBcBggr
# BgEFBQcwAoZQaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcnQwCQYDVR0T
# BAIwADANBgkqhkiG9w0BAQsFAAOCAgEA0yVWE59ZytC1egGLlmnUVBJk6TmpFZ2s
# dl8UtpZvb8YvDM105QhMGPtnEd4ffoqPqvgQwU7GZe7ZXrWxUu0C/ui5R5sp0fFI
# eahFBPc7cfz54jD/z+AIYDmw+Q/RgFCkAY9N2OF1KNjssKhj6cd6Z7aSc3Zj7FG3
# crXhXAmUWVosvFunEKkHXWXYbpv8edv8FC8ASvVUmVqdrHaXXSS8HigZEh/HE+XK
# A+CbBy2vQvwHq12brc7tkpSk6r15aG+RRdWmP8BirKeNYOzMZNP3XcgemmaK1SjO
# jOw/A3zyQXNEaDiAULvze1gtf8r6WT/nItgthpvKQhFejNhaAaBqlrS1YbOSvTtK
# CZMsKSTb+DEbN0dG/wcnJ4vWk4dOrgdgIDpNBhPy7q7l1v+woOWRH5UJsGNq0oFn
# wxOEdKYJ5Qn+5EMw++NMax1VlJaRrDL1nTPJudpuhpf1h1JOPhiNBsJHtCJXcxX/
# n6SUpn/VR+6Y0Lx/Knii2f8wZRFd8pCbnDLlQbwR1AxlGbQ9FlICmy+rIk+gHXC4
# 7P2JRO6uOBQcbwQDFUFC882CtKHhUtveU39LUBzkhPBByqx0e1ACcUyRIMwj4pC1
# ZS6sTPp622OBbsv0NKXZIpaSdcsF7Lak56ZQwHlO9tUDKm9KzVQHrp2v/0tdv9cz
# moABt8TK7rsxghpqMIIaZgIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5E
# aWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2Rl
# IFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTECEAHJkf0nnQCyP+gcdt4d
# yXMwDQYJYIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAv
# BgkqhkiG9w0BCQQxIgQghKTeQo4wlnwg98IUTiyj/+C+O2e4eLfHnIhivwSFUjcw
# DQYJKoZIhvcNAQEBBQAEggIAyn35JB1Cpg1X+LqEj57WKzfrqol7SvOUtZPKwH89
# otMOuv1qku525knNe6IsTmmpJAxk3TQmVZYJOeiBAcWxobgjKjfmkbuPA1n0z1Ph
# NpUxyUeWFQYmJKz4OMahxQM+IiScF8DaRz0+pOmQq7LTHG/RKE9qgVpFUUv5wHvC
# cEQUPgUn+v0HeX40+7252edU7UOkZbeUMwxn5qhJ1QDYqUxCM6ziTiOtl0gkVzqf
# UcOsY2n1oERyREWRanep+1EXiD8uixcHPoJyLO/6o7sxWdRJdYl7F5KvC323T9Go
# Uwu7K1U4zYLlmK0U3go42/ffFaCtjtJE6ZkT2a+2rM9231tJ0h/WrrV3UxYsqtIt
# ++AVS2bVTI9dWOg92YZXkTlKizqBZApzNKRdNnR1i9kbX2zwwlE+X2s4p/e9fv3d
# i44b8mMsGit1sOW8iPIpNuFZNT9Rg8/YD1JNspHTWeNCl88frl+r2pAPG0tbKvr7
# 3FlWx1n5AOgCnMLG3/9gd6g4Qx1iRy77gxYme7V4TN4hOPghSiyMKW9tVnGKEF9Z
# 9VzJ3OOsdPsbTCACh6oFluX4hfnxI1zo+B6oNE5zZ1BdxcFWc+74JELll+WLc4Ba
# nffgucCu5p5x0+voPelePdfIgQuY/hRl9kec3H+p7E0TMQdKPK1jZ+T+dNP9/o+8
# IO2hghdAMIIXPAYKKwYBBAGCNwMDATGCFywwghcoBgkqhkiG9w0BBwKgghcZMIIX
# FQIBAzEPMA0GCWCGSAFlAwQCAQUAMHgGCyqGSIb3DQEJEAEEoGkEZzBlAgEBBglg
# hkgBhv1sBwEwMTANBglghkgBZQMEAgEFAAQgtsRdMIL3Dmnc2AUXopGxZ3EKrRhU
# 2Y6ZtGFAJRHWsDMCEQCwAhkSyawEM/uFy2LwzxRWGA8yMDIzMTEwNjE3MTE1OVqg
# ghMJMIIGwjCCBKqgAwIBAgIQBUSv85SdCDmmv9s/X+VhFjANBgkqhkiG9w0BAQsF
# ADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNV
# BAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1w
# aW5nIENBMB4XDTIzMDcxNDAwMDAwMFoXDTM0MTAxMzIzNTk1OVowSDELMAkGA1UE
# BhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSAwHgYDVQQDExdEaWdpQ2Vy
# dCBUaW1lc3RhbXAgMjAyMzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AKNTRYcdg45brD5UsyPgz5/X5dLnXaEOCdwvSKOXejsqnGfcYhVYwamTEafNqrJq
# 3RApih5iY2nTWJw1cb86l+uUUI8cIOrHmjsvlmbjaedp/lvD1isgHMGXlLSlUIHy
# z8sHpjBoyoNC2vx/CSSUpIIa2mq62DvKXd4ZGIX7ReoNYWyd/nFexAaaPPDFLnkP
# G2ZS48jWPl/aQ9OE9dDH9kgtXkV1lnX+3RChG4PBuOZSlbVH13gpOWvgeFmX40Qr
# StWVzu8IF+qCZE3/I+PKhu60pCFkcOvV5aDaY7Mu6QXuqvYk9R28mxyyt1/f8O52
# fTGZZUdVnUokL6wrl76f5P17cz4y7lI0+9S769SgLDSb495uZBkHNwGRDxy1Uc2q
# TGaDiGhiu7xBG3gZbeTZD+BYQfvYsSzhUa+0rRUGFOpiCBPTaR58ZE2dD9/O0V6M
# qqtQFcmzyrzXxDtoRKOlO0L9c33u3Qr/eTQQfqZcClhMAD6FaXXHg2TWdc2PEnZW
# pST618RrIbroHzSYLzrqawGw9/sqhux7UjipmAmhcbJsca8+uG+W1eEQE/5hRwqM
# /vC2x9XH3mwk8L9CgsqgcT2ckpMEtGlwJw1Pt7U20clfCKRwo+wK8REuZODLIivK
# 8SgTIUlRfgZm0zu++uuRONhRB8qUt+JQofM604qDy0B7AgMBAAGjggGLMIIBhzAO
# BgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEF
# BQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgw
# FoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFKW27xPn783QZKHVVqll
# MaPe1eNJMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5j
# cmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdD
# QS5jcnQwDQYJKoZIhvcNAQELBQADggIBAIEa1t6gqbWYF7xwjU+KPGic2CX/yyzk
# zepdIpLsjCICqbjPgKjZ5+PF7SaCinEvGN1Ott5s1+FgnCvt7T1IjrhrunxdvcJh
# N2hJd6PrkKoS1yeF844ektrCQDifXcigLiV4JZ0qBXqEKZi2V3mP2yZWK7Dzp703
# DNiYdk9WuVLCtp04qYHnbUFcjGnRuSvExnvPnPp44pMadqJpddNQ5EQSviANnqlE
# 0PjlSXcIWiHFtM+YlRpUurm8wWkZus8W8oM3NG6wQSbd3lqXTzON1I13fXVFoaVY
# JmoDRd7ZULVQjK9WvUzF4UbFKNOt50MAcN7MmJ4ZiQPq1JE3701S88lgIcRWR+3a
# EUuMMsOI5ljitts++V+wQtaP4xeR0arAVeOGv6wnLEHQmjNKqDbUuXKWfpd5OEhf
# ysLcPTLfddY2Z1qJ+Panx+VPNTwAvb6cKmx5AdzaROY63jg7B145WPR8czFVoIAR
# yxQMfq68/qTreWWqaNYiyjvrmoI1VygWy2nyMpqy0tg6uLFGhmu6F/3Ed2wVbK6r
# r3M66ElGt9V/zLY4wNjsHPW2obhDLN9OTH0eaHDAdwrUAuBcYLso/zjlUlrWrBci
# I0707NMX+1Br/wd3H3GXREHJuEbTbDJ8WC9nR2XlG3O2mflrLAZG70Ee8PBf4NvZ
# rZCARK+AEEGKMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG
# 9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkw
# FwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVz
# dGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBjMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRp
# Z2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENB
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFVxyUD
# xPKRN6mXUaHW0oPRnkyibaCwzIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8zH1AT
# CyZzlm34V6gCff1DtITaEfFzsbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW
# 1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iEZLRS
# 8nZH92GDGd1ftFQLIWhuNyG7QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXmG6jB
# ZHRAp8ByxbpOH7G1WE15/tePc5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCY
# Jn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucf
# WmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLc
# GEh/FDTP0kyr75s9/g64ZCr6dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkrqPNF
# YLwjjVj33GHek/45wPmyMKVM1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKowSYI
# +RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3IXjAS
# vUaetdN2udIOa5kM0jO0zbECAwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYBAf8C
# AQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX
# 44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggr
# BgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3Nw
# LmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDag
# NIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RH
# NC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3
# DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJL
# Kftwig2qKWn8acHPHQfpPmDI2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwIgqgW
# valWzxVzjQEiJc6VaT9Hd/tydBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2M
# vGQmh2ySvZ180HAKfO+ovHVPulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAngkSu
# mScbqyQeJsG33irr9p6xeZmBo1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJ
# xLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9P2un
# 8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SV
# e+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Ziza4
# k9Tm8heZWcpw8De/mADfIBZPJ/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJ
# Dwq9gdkT/r+k0fNX2bwE+oLeMt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr
# 5n8apIUP/JiW9lVUKx+A+sDyDivl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCCBY0w
# ggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEMBQAwZTELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENB
# MB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkGA1UEBhMCVVMx
# FTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNv
# bTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zCpyUuySE98orY
# WcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf1gU8Ug9SH8ae
# FaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x4i0MG+4g1ckg
# HWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEioZldXn1RYjgwr
# t0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7axxLVqGDgDEI3Y
# 1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZOjFEmjNAvwjX
# WkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJl2l6SPDgohIb
# Zpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz2cXfSwQAzH0c
# lcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH4b235kOkGLim
# dwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb5RBQ6zHFynIW
# IgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ9eRpL5gdLfXZ
# qbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFOzX
# 44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3z
# bcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGG
# GGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2Nh
# Y2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDBF
# BgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkqhkiG
# 9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs7IVeqRq7IviH
# GmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq3votVs/59Pes
# MHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/Lwum6fI0POz3
# A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9/HYJaISfb8rb
# II01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWojayL/ErhULSd+
# 2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDGCA3YwggNyAgEBMHcwYzELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdp
# Q2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQ
# BUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMx
# DQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTIzMTEwNjE3MTE1OVowKwYL
# KoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmcz0AwLwYJKoZI
# hvcNAQkEMSIEIOBZR+nXph68bdz+RRG+uVBfFkIKoPBZ3rZOHv/ppzwKMDcGCyqG
# SIb3DQEJEAIvMSgwJjAkMCIEINL25G3tdCLM0dRAV2hBNm+CitpVmq4zFq9NGprU
# DHgoMA0GCSqGSIb3DQEBAQUABIICAGhxDPtnF77S2YA6bPZelSDDOyQ/mcq8qCKE
# qx9zc2OmGSmVh2DYLtcnRxlM/3Rul1oYwC3RBE30iTEuAqL8zgw5zbmGu6ir+Zu8
# 6HdMv5W0DvAhPP1ErlQ15Jggs5/mE5j8GrP8mJNoyWaLoz2YQtzMmOAO9Mmcum2F
# AOaiSy17csOr9HOTEqPmmeQZpbgNCZXL1HjLiv2h7PFGU5BGYeU8aDLbhUu04I1F
# VoCfkgSlUZq/1AWZydijYO69LV+R1T6UIlcj69MwYcTTVwWaJFkmXLORiT1q6Q+s
# 5UjvxTc7oeAASUQYTwp2Zb+L4CUEMH6bcalgVv3ZITSooNCPv5eejUKbEPGxtQWs
# qkdrjNTJLg92q5ujTZYXFy2XicM1EMRdJ7jJXByNaNt4+zxYWsSUkYejz5h2XlYK
# m1GEXVJKkDIA7Fg8BedM1W1HQGIhjukfJX2SbjX5EucOzpLIOen9BQojVptR+jKr
# i9RzNzcwecnksd8J5aDd6n1J+6rwux8HguMeYBPJkMh5Q3pmQqRHwiCH5DQowGEU
# wZdkbwziWmQB0cN7zwlUpFROnLXwHNl8MiB0faWIiQTTTWJp40nF86VzGlrrJY+l
# C0rs8Isne2vbWY7B++rKD5mJNCdjoDqw1GqiFSVtme3Yu8mNUpDkA7hiB4iJEq9Z
# ywKYa/y7
# SIG # End signature block
