Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
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
# MIIpowYJKoZIhvcNAQcCoIIplDCCKZACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCD5AHw/DZwF37Lf
# hSZ8sWJ/pdeFGRmL03qbQlJJfvoN2qCCDpEwggawMIIEmKADAgECAhAIrUCyYNKc
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
# yK+p/pQd52MbOoZWeE4wggfZMIIFwaADAgECAhAHzYbPdL0G4DP0mj8QhQwXMA0G
# CSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjMwMTExMDAwMDAwWhcNMjQwMzAy
# MjM1OTU5WjCB3jETMBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8AgEC
# EwhEZWxhd2FyZTEdMBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEDAOBgNV
# BAUTBzI5MzM2MzcxCzAJBgNVBAYTAlVTMRYwFAYDVQQIEw1NYXNzYWNodXNldHRz
# MRIwEAYDVQQHEwlDYW1icmlkZ2UxIDAeBgNVBAoTF0FrYW1haSBUZWNobm9sb2dp
# ZXMgSW5jMSAwHgYDVQQDExdBa2FtYWkgVGVjaG5vbG9naWVzIEluYzCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAKkC2pEjLYnjLtkW+Vkz3mCe+wElX+k7
# AgEtGOL+rqaYNF9CdS8veLyZY6fQeq/ugDkdGuKdz0oXGlzTaVgnOcd1TZrVSeVR
# KiE9/gO1mSP/kuyJPKFMDUNR4LE5+j5chSCyLoKhmsAFdus/KH6ZizjcM4rtTkNs
# 714lHQ91LssdoX+rZXhn/ttsiEtOG4dAZdntDv4aDjI/lde5DouV9k/ISKPTrvmF
# obsrEUxqfOwynq8yqVaQMABw8aeA0ajU6EgD+4gGG8TaFNxQZOPgAZNWYpqwbnlR
# f35mgl4HufEPVaHwN8158jpippKW7iUFTvV5zpmcd6T1DMWtoePcRLm/unvosA0g
# DHn/hZO+GdQ4IbJ70oObq497Xwp02iGP4b/dNHQF3XV92Y262v0c1WkaAVAOHMFP
# nJVp7FAUS2I3Zfqu/R2ZjSUfXPtWg2ar+HGZ4tAnc6Zd5uS+Ggyf5jUA2rz9r0wT
# fxei07j2A1F5/kvpUMevzkEE2aWWeKQrqiSIPT48j2VoMM9zQD3v7tGvzAHk9SSi
# SSOM6NZWwDROdTSXn5pCNzEwfy7OinP33qSZWC1Omx3GNPtHVGcBGOZCwbNBiz2i
# EwR4HyJvuxZjeam5dM5zuuCoyYrxLINVlcLFpbg7uAMaM0WTf52/SB2040aDeSzi
# kVgXUiWy9MnxAgMBAAGjggIFMIICATAfBgNVHSMEGDAWgBRoN+Drtjv4XxGG+/5h
# ewiIZfROQjAdBgNVHQ4EFgQUAgywME/nFo30YHtViHhRyLCj41MwDgYDVR0PAQH/
# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMIG1BgNVHR8Ega0wgaowU6BRoE+G
# TWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENvZGVT
# aWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3JsMFOgUaBPhk1odHRwOi8vY3Js
# NC5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JTQTQw
# OTZTSEEzODQyMDIxQ0ExLmNybDA9BgNVHSAENjA0MDIGBWeBDAEDMCkwJwYIKwYB
# BQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCBlAYIKwYBBQUHAQEE
# gYcwgYQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBcBggr
# BgEFBQcwAoZQaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcnQwDAYDVR0T
# AQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAqItOsemfwmwzLKUyPRVuyuXhMpWM
# iHQqfsSloP6KdVwtTMQBP1lmxsE1qAQ3R52iCiGAra7dvZRUm3mWXTntXQwXUEqH
# dguy53+VrZ7f+BtZiL51OJOJXyiy3lSA+rrr7g1Xuz2ax+tRLqkmmOswYoPSnSIc
# EhGyaoLKFX19/agk6tiZzVdzbz5N/aPFKAng0BkilTvSI8JJDHyO2lxhHzZ3zPFf
# 51pxBn7+HkeRdLQ2aSy4j8Y8P2sMWPOhs2EjDJ14wHZIPHMHorI40AnPVOQjJ1h1
# ME/eh2HVCQMf1BIDc7ZXkHX6mW6BbLxTuWhxiPcTKvj3/HO+VyeEjTgT0+NHCEiQ
# +LFudP/MYR7T8Vy2Zsg0HnNXAsC2JjDLLu/Ce69Xlh3ntc0jiQtT0X38ZMXwUSA+
# 7jgNe93Wx4GLjzw9MfOXYwqRAWC2dUXcUWKUHGpreX4wRQjemFMifnaEOfWJZZ5w
# mkGJkfh0XmVfFFg4aE6LidoqcKvlXfpzNxEsBTJUeETPdaiYHhJT5M7YgQiAuJd6
# bQj67m/lutkBz5ucXuOSte3wddC4PmFMCkrJ/3ZLk5se0Tcq1+Zxj2IDNXUkO14p
# 0lGr0mLiEBXIJB0/RTdrCNQXTgfBfm/2JGm11XnKxWYr7iRxZwWjh5V/FJYO6kHc
# JZzQBtUCg02o9ogxghpoMIIaZAIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
# Ew5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBD
# b2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTECEAfNhs90vQbgM/Sa
# PxCFDBcwDQYJYIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
# FTAvBgkqhkiG9w0BCQQxIgQghKTeQo4wlnwg98IUTiyj/+C+O2e4eLfHnIhivwSF
# UjcwDQYJKoZIhvcNAQEBBQAEggIAUyvA/Nyq81oXaJhaux9xIn/MFWdAi2arZGDJ
# ZMVgwB7uIEwCdu82zpQUVjXi11QsfRk++fXJDLX2YLJoGqpHp5pVvH3awmAMey0J
# QXfVBjeeP/dH8MXYp7wE4FZwN45DcDoTvttKMGNnkQMCHZqkfRDjjjLq4HDSjtNy
# a/2fSXMFCR1SfuUYLJG1gsHdVGwS1N59mHkDf6ZS8x0SD5HsFIqzEFrG0Nsd45EL
# JMhRT5+DcQggsB5o+hWQRbw/5hh2nZdxSFTZ3gbc0HlP6KB5ev7Y/bZCr34ZGuZD
# XrlqNJswCANi8CGuIWk8em1uBOF+EVRTCzm9Kh14HLxMbxWYKZZ1a3eSQaickx3G
# eUyPZz+bmvQ51oALCLxz5DP8kzvf3UQaV9KbGP3qk/wCzhcJisSL47k2A3ZpP/pC
# z1gdnLLxvh7C+EZZBica2Ha0FPUds9HFiGDxE0lyxmOkKnuciKFHVGmL88Xr6XV7
# Dg0tx0hkmUp4yHA/9MKOLIDT3gGRfFuEhxMeT3uvustOIkZJPdVA6HfRYiuDHNYS
# re+TOJeWZ9P9c0rLtOcibOurRKcYgXRXPWs2mSBEXuuXsFdqE7ZzR/eMVDErV3GZ
# hIgl3nqpB8kozvw1New0+JbrkmJfnDremQnhatFVFQbEIAueDJN7XeocqPgc5b19
# YTnLqT+hghc+MIIXOgYKKwYBBAGCNwMDATGCFyowghcmBgkqhkiG9w0BBwKgghcX
# MIIXEwIBAzEPMA0GCWCGSAFlAwQCAQUAMHgGCyqGSIb3DQEJEAEEoGkEZzBlAgEB
# BglghkgBhv1sBwEwMTANBglghkgBZQMEAgEFAAQgC44U39DQN6505yLkhoNmGOIW
# pcjt06CJRY8/lwR8GfYCEQCsy5fkKgVP4mmCwCxTZQTwGA8yMDIzMDQyNTE3MTYw
# NVqgghMHMIIGwDCCBKigAwIBAgIQDE1pckuU+jwqSj0pB4A9WjANBgkqhkiG9w0B
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
# MQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yMzA0MjUxNzE2MDVaMCsG
# CyqGSIb3DQEJEAIMMRwwGjAYMBYEFPOHIk2GM4KSNamUvL2Plun+HHxzMC8GCSqG
# SIb3DQEJBDEiBCCmeivWrAnPIx1v2v3V5tellBMXaoJ8q4vUI6el5sLHlzA3Bgsq
# hkiG9w0BCRACLzEoMCYwJDAiBCDH9OG+MiiJIKviJjq+GsT8T+Z4HC1k0EyAdVeg
# I7W2+jANBgkqhkiG9w0BAQEFAASCAgCmLjTbwEBsLsyIHdY7Y1Qo/TnLyzVc5eWb
# F2aui6g9nJanYPQsuiM+FAJ97z+qL9sAhpnK2NPvELCtosOWLZCHc7VQQzNrkJXp
# 15r+KeZ9MKnQL1j1cTYHnw7MqXNfloSzdAAtz9BWAbA2j7Fh9zVjFo9b6bWytcCb
# Y6oBi9AKOmI6WwY/a0fyIAv1C2hZzJHKdz0KAqODRe93DtzWGXti84c7kuw5kMCM
# +16kjqh5b7mFX60phS+IprLAF1/oRUF+vItZo8KJnBisYtM6vW8doSKblAFBM6Ds
# MjMoRwXpCgnbgaK/k3RHwddqFZROKntZ9JG7HesmpyinrmsQ6baOo32r/ndWBPA3
# nCi8D34jmp6ILLFoYS9EzILPO3Uu4ltIVdBhpCa/aPTBa6/Yq5asCKjaRx445/ro
# HHtMTrKJqGT9AEsiWqZs4QQy51qHzkciFgrGAmeSUpaQ55cN/Nc8khfJeLwZwVHV
# lu2/EhsvTizvHEZwcoRYrMrkwmQhywHxoQFaq5sdtHZmkrcbiUjzwF1V6Gy5LBAo
# GimMUBylB103yzWrI1anXPugqEH5G2BRGrkMdWSHErJjQ1tTjLAhhrjOwyQE55Ty
# sY9jmctJyrCsx4I+a/+97M0JWn3Y38ZMDH+6CmSwaNkWTGOtc+io5h+tkzyKlcgL
# qENRxWcXdQ==
# SIG # End signature block
