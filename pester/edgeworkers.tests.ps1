Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestGroupID = 209759
$Script:TestContract = '1-1NC95D'
$Script:TestEdgeworkerName = 'akamaipowershell-testing'
$Script:TestEdgeworkerVersion = '0.0.1'
$Script:BundleJson = '{ "edgeworker-version": "0.0.1", "description" : "Pester testing" }'
$Script:MainJS = 'export function onClientRequest (request) {}'

Describe 'Safe Edgeworker Tests' {

    BeforeAll {
        it 'EW should not already exist' {
            { Get-EdgeWorker -Name $TestEdgeworkerName -EdgeRCFile $EdgeRCFile -Section $Section } | Should -BeNullOrEmpty
        }
    }

    ### List-EdgeWorkerResourceTiers
    $Script:Tiers = List-EdgeWorkerResourceTiers -ContractId $TestContract -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-EdgeWorkerResourceTiers returns tiers' {
        $Tiers | Should -Not -BeNullOrEmpty
    }

    ### List-Edgeworkers
    $Script:EdgeWorkers = List-EdgeWorkers -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-Edgeworkers returns EWs' {
        $EdgeWorkers | Should -Not -BeNullOrEmpty
    }

    ### List-EdgeworkerGroups
    $Script:EdgeWorkerGroups = List-EdgeWorkerGroups -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-EdgeworkerGroups returns groups' {
        $EdgeWorkerGroups | Should -Not -BeNullOrEmpty
    }

    ### List-EdgeWorkerGroupReports
    $Script:Reports = List-EdgeWorkerReports -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-EdgeWorkerGroupReports returns reports' {
        $Reports | Should -Not -BeNullOrEmpty
    }

    ### Get-EdgeworkerGroup
    $Script:Group = Get-EdgeWorkerGroup -GroupID $TestGroupId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-EdgeWorkerGroupReports returns reports' {
        $Group | Should -Not -BeNullOrEmpty
    }

    ### New-EdgeWorker
    $Script:EdgeWorker = New-EdgeWorker -name $TestEdgeworkerName -GroupID $TestGroupID -ResourceTierID 100 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-Edgeworker completes successfully' {
        $EdgeWorker.edgeWorkerId | Should -Not -BeNullOrEmpty
    }

    ### Get-EdgeWorker by name
    $Script:EdgeWorker = Get-EdgeWorker -Name $TestEdgeworkerName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-EdgeWorker by name returns EW' {
        $EdgeWorker.edgeWorkerId | Should -Not -BeNullOrEmpty
    }

    
    ### Get-EdgeWorker by name
    $Script:EdgeWorker = Get-EdgeWorker -EdgeWorkerID $EdgeWorker.edgeWorkerId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-EdgeWorker by ID returns EW' {
        $EdgeWorker.edgeWorkerId | Should -Not -BeNullOrEmpty
    }

    ### Set-EdgeWorker
    $Script:EdgeWorker = Set-EdgeWorker -Name $TestEdgeWorkerName -NewName $TestEdgeWorkerName -GroupID $TestGroupId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-EdgeWorker returns EW' {
        $EdgeWorker.name | Should -Be $TestEdgeWorkerName
    }

    ### New-EdgeWorkerVersion with directory
    New-Item -ItemType Directory -Name $TestEdgeworkerName
    $BundleJson | Set-Content -Path "$TestEdgeworkerName/bundle.json"
    $MainJS | Set-Content -Path "$TestEdgeworkerName/main.js"
    $Script:NewVersion = New-EdgeWorkerVersion -Name $TestEdgeworkerName -CodeDirectory $TestEdgeworkerName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-EdgeWorkerVersion creates a new version and removes it successfully' {
        $NewVersion.edgeWorkerId | Should -Be $EdgeWorker.edgeWorkerId
    }

    ### Remove-EdgeWorkerVersion
    it 'Remove-EdgeWorkerVersion completes successfully' {
        { Remove-EdgeWorkerVersion -Name $TestEdgeworkerName -Version $TestEdgeworkerVersion -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    <#
    ### New-EdgeWorkerVersion with codebundle
    $Script:NewVersion = New-EdgeWorkerVersion -Name $TestEdgeworkerName -CodeBundle "$TestEdgeworkerName\$TestEdgeWorkerName-$TestEdgeWorkerVersion.tgz" -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-EdgeWorkerVersion completes successfully' {
        $NewVersion.edgeWorkerId | Should -Be $EdgeWorker.edgeWorkerId
    }
    #>

    ### Get-EdgeWorkerVersion
    $Script:Version = Get-EdgeWorkerVersion -Name $TestEdgeworkerName -Version $TestEdgeWorkerVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-EdgeWorkerVersion returns the version' {
        $Version.edgeWorkerId | Should -Be $EdgeWorker.edgeWorkerId
    }

    ### List-EdgeWorkerVersions
    $Script:Version = List-EdgeWorkerVersions -Name $TestEdgeworkerName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-EdgeWorkerVersions returns at least 1 version' {
        $Version.edgeWorkerId | Should -Not -BeNullOrEmpty
    }

    ### Remove-EdgeWorker
    it 'Remove-EdgeWorker completes successfully' {
        { Remove-EdgeWorker -EdgeWorkerID $EdgeWorker.edgeWorkerId -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    AfterAll {
        Remove-Item -Recurse $TestEdgeworkerName
    }
    
}

Describe 'Unsafe Edgeworker Tests' {
    ### Activate-EdgeWorker
    $Script:ActivationResult = Activate-EdgeWorker -EdgeWorkerID 12345 -Version 0.0.1 -Network STAGING -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Activate-EdgeWorker returns valid response' {
        $ActivationResult.edgeWorkerId | Should -Not -BeNullOrEmpty
    }

    ### List-EdgeWorkerActivations
    $Script:Activations = List-EdgeWorkerActivations -EdgeWorkerID 12345 -Version 0.0.1 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'List-EdgeWorkerActivations returns valid response' {
        $Activations[0].activationId | Should -Not -BeNullOrEmpty
    }

    ### Get-EdgeWorkerActivation
    $Script:Activation = Get-EdgeWorkerActivation -EdgeWorkerID 12345 -ActivationID 1 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-EdgeWorkerActivation returns valid response' {
        $Activation.edgeWorkerId | Should -Not -BeNullOrEmpty
    }

    ### Remove-EdgeworkerActivation
    $Script:ActivationCancellation = Remove-EdgeWorkerActivation -EdgeWorkerID 12345 -ActivationID 1 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-EdgeWorkerDeactivation returns valid response' {
        $ActivationCancellation.edgeWorkerId | Should -Not -BeNullOrEmpty
    }

    ### Deactivate-EdgeWorker
    $Script:DeactivationResult = Deactivate-EdgeWorker -EdgeWorkerID 12345 -Version 0.0.1 -Network STAGING -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Deactivate-EdgeWorker returns valid response' {
        $DeactivationResult.edgeWorkerId | Should -Not -BeNullOrEmpty
    }

    ### List-EdgeWorkerDeactivations
    $Script:Deactivations = List-EdgeWorkerDeactivations -EdgeWorkerID 12345 -Version 0.0.1 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'List-EdgeWorkerDeactivations returns valid response' {
        $Deactivations[0].deactivationId | Should -Not -BeNullOrEmpty
    }

    ### Get-EdgeWorkerDeactivation
    $Script:Deactivation = Get-EdgeWorkerDeactivation -EdgeWorkerID 12345 -DeactivationID 1 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-EdgeWorkerDeactivation returns valid response' {
        $Deactivation.edgeWorkerId | Should -Not -BeNullOrEmpty
    }

    ### List-EdgeWorkerProperties
    $Script:Properties = List-EdgeWorkerProperties -EdgeWorkerID 12345 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-EdgeWorkerDeactivation returns valid response' {
        $Properties.count | Should -Not -Be 0
    }

    ### Get-EdgeWorkerAuthToken
    $Script:Token = Get-EdgeWorkerAuthToken -Hostname www.example.com -Expiry 60 -Network STAGING -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-EdgeWorkerDeactivation returns valid response' {
        $Token | Should -Not -BeNullOrEmpty
    }
}
# SIG # Begin signature block
# MIIgEgYJKoZIhvcNAQcCoIIgAzCCH/8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDsDDScOSdXLZaK
# bvuJO5tKs1I7kXROyswJazVbBkdREKCCDsEwggawMIIEmKADAgECAhAIrUCyYNKc
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
# FTAvBgkqhkiG9w0BCQQxIgQgodi+kee26g8oyGqKbROTZH1FKy22Zzx3RDHnskaN
# IAwwDQYJKoZIhvcNAQEBBQAEggIAFn3o5XK/mJOP5aTf5/Rk9zwKlejPtyMs8e4L
# z6RxfhEpExcfen8S3/cjU1Q1nqeXzp9hRBi9n5n2ALea2N7oDmwFu8c25Pl6tFHh
# aJXshAA2A9sRo+Sju5WiNGSSuD83Bvl0G/asi3Jnze6OZGSYC/NiLlxzYbbsiDZp
# tjwXUN/j1/mTSm4lhqfzTHf3V4CXUHiq1gnyp9ZJmoE5ajvSUhfhOLBhDoO61wyJ
# VCODUhR6+ND8eTAO5IwFAxg6vCgfLpOPxHTFAwE3f+KK4HtdLEqZCdjvhLDomQIk
# f26+vGQQm8jVIHmq+V/9rDHnx88A0heQP+Q15+VhP74t5hsYiDRXcc/mO+HkXF2R
# jj/hTHHShMi4Ef3zgngWRVIM0Z2TXaiynjQU52O5PjNjTrbHbsAe9rtbnWSUq9Hf
# QDdFc4Hi+mw2iYvM097B9R+PvjrpD8iBGiZpotSwnd0u0S3rO2yJs1yaMgOOMmih
# 921cbSfJ0eBKwplPbK+8Up6vxT5KWOA/gOjq9exPI0Ge1t4lOirdXNw+hIKENW8u
# em6StslH8O8dJ4np+aMtjY3agbWHdt4jAAYctFTkXxaiWhjQ1lFpJPukYVYwQ/Jp
# 1DuEmq7Tucc1iiHhzmjV4m7Ojds4h4iWFusQaXY3Ugk4Xyr2DU2gF6SpKsImCpnn
# zPb/cZyhgg19MIINeQYKKwYBBAGCNwMDATGCDWkwgg1lBgkqhkiG9w0BBwKggg1W
# MIINUgIBAzEPMA0GCWCGSAFlAwQCAQUAMHcGCyqGSIb3DQEJEAEEoGgEZjBkAgEB
# BglghkgBhv1sBwEwMTANBglghkgBZQMEAgEFAAQgJc0J6JlOVJ4GuJZgKhllrf58
# RHyljbfYUnyqYqt6hVUCED0CapQbFdXKJzqqQ8WCY24YDzIwMjIwMzIzMTg0MzQ4
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
# MjAzMjMxODQzNDhaMCsGCyqGSIb3DQEJEAIMMRwwGjAYMBYEFOHXgqjhkb7va8oW
# kbWqtJSmJJvzMC8GCSqGSIb3DQEJBDEiBCDrQxwCFLhEIgbX55L2sJoXrLoLUPtA
# 8r1XfVensbVO/zA3BgsqhkiG9w0BCRACLzEoMCYwJDAiBCCzEJAGvArZgweRVyng
# RANBXIPjKSthTyaWTI01cez1qTANBgkqhkiG9w0BAQEFAASCAQCSJHxBM/v3jw4Y
# HJaRVToerK2/v5+qCPnUOmbTKonYc2EgEqwk3YN8qBXA7wr7lSeXEdueXrlUhhj+
# DENHeG6xSAm030KJSeOsiioH/IniIiS2CPi30GZ+jnwxABB0VfLNfJF2ZLKFK5Ka
# O26QvQYMAD2SLZuLRsqEuwf+NoLVj4epN3y6fDHzPgMiCBQJKxLKyyxW0a290K/u
# /J+3szVxa9ECZ0ZUpj8QNt5i8LqwJTdnMJPFDc81XP3QUnIP8jSo7GKIm4nTxUBg
# sFMRnYGhWen3BnuHlAUVtQ23q+I7G43BiAfzvkkh8RkjJfluHdeG5yIUVqO+aB3+
# lKsv6Yzj
# SIG # End signature block
