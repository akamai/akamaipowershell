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
# MIIp2QYJKoZIhvcNAQcCoIIpyjCCKcYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDRUeWsV5sQw9dL
# A95NwKJUYaD+NUiTtRaLt146K3LAIKCCDsEwggawMIIEmKADAgECAhAIrUCyYNKc
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
# FTAvBgkqhkiG9w0BCQQxIgQgqVZxNWH1SjlfYhLQjkoddvqrVt3sTwD5InWOywSF
# VyswDQYJKoZIhvcNAQEBBQAEggIAcbEF2uMU65cVVyWkx+g8nJSByhLNvCvdwUPQ
# gJDpsuSpcdypUuC0lImfOWt5w2FFIArdLFmW1CypH0Cor7yHcnCO3Ngv/Eidk9NP
# JRzvjWSGRBhqDMyG0ili5AXrJ+KnxXcYxwclBVcoVoH1VMOPnTjyBXvgfiA8A9yh
# 4l25qNKiYkxeLqIW2dW85j0a2zcFqw9m+KNTn6TExO8tYD3v2O68DZdOAE5HXirk
# Xkbl+vyn2g8INoV70tzct8WbIfoOe7cQIA4vqCv/bpVt2wADj6o/IZdKm5V/CTHu
# Y+rWlGAZIJngxgXeC3+cniPqCHlRtBPQYCTq9xv0Cv2YzF5fIAddMXR5fuk64KFG
# sie9mtHqFNmKcBmwP4A0PPi0Eo6GQAVod5z5qr9Qb7w37CqzkI25tw6Zr5250Tc7
# jJkucvrnH/JeBtgCnTHmVvfjib4fKq0M/ZKr9ADBO0kq4HR2FH8aAVemrZyM28Df
# C/X943AW6G7HKtTD9JuXhZTFHgw+PI8VR7wgTUnAySQqIlo0tJNM8dxVPoNO0jlg
# nfhvdHz5yJ5CNe5z9pIXnOMqSkJzs0Z+c6J26y9ze1Z9t5g03E4DvS3x/NpP6pRE
# Y3GRUTWh+urPIlCk0jTObVEXLXQc8dyZ8mWWLTrVyY+3cvIAts+0jc3cSwwFOQ3A
# Jni5Of2hghdEMIIXQAYKKwYBBAGCNwMDATGCFzAwghcsBgkqhkiG9w0BBwKgghcd
# MIIXGQIBAzEPMA0GCWCGSAFlAwQCAQUAMHgGCyqGSIb3DQEJEAEEoGkEZzBlAgEB
# BglghkgBhv1sBwEwMTANBglghkgBZQMEAgEFAAQgcbTPORPFMjzf4IRq4EPI9IgH
# Dr+RwykDwATXTj08KbUCEQDaRZFK8kUN+v7g+tT4hSq5GA8yMDIyMDkxNTE4NDcx
# MlqgghMNMIIGxjCCBK6gAwIBAgIQCnpKiJ7JmUKQBmM4TYaXnTANBgkqhkiG9w0B
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
# hvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yMjA5MTUxODQ3
# MTJaMCsGCyqGSIb3DQEJEAIMMRwwGjAYMBYEFIUI84ZRXLPTB322tLfAfxtKXkHe
# MC8GCSqGSIb3DQEJBDEiBCA2QNW/zm9cVTD2R+KoA0Q3PY4ad+ZaMHID8SGctveQ
# /zA3BgsqhkiG9w0BCRACLzEoMCYwJDAiBCCdppAVw0nGwYl4Rbo1gq1wyI+kKTvb
# ar6cK9JTknnmOzANBgkqhkiG9w0BAQEFAASCAgCyJEZNJE+10wLdEBn2tbOci34c
# LLQyrtwG5h9SIT5GUThclQiRG2AupBt2AtEHiYm+/LWcfFGiDuEze4RT6vE3M54+
# DuFxB2unTQfXMzYvXUKL/cY4OueRBsjhQUIQ0lOAN2YecwOFmyYZGnCyjyhXxFO7
# meZX1+CL9mQ4UUGFWHi6fLYdD0Vps0UaZksw4RtD0TGXU3nye4V8RWINbMIjNoEy
# Ak/5moKVqAFwILSjWGZoto4AbZzUvB5Nefg+PYPXmlWBTRVe0+msFaeCLtQm05ZX
# dum8iG/4VqnvSoLmLc4xVHS79YPf4UgUDDxYkziX30aLiIU2lN7L2il6uTuMXTLl
# YYxFWXglSQDD40Iz0UX76aT+Hj0vtMANpsWJF+5YrV8WhYD6xojuialL9FQVCmjN
# RlMQZ+cIbgAWFO1auLa0IvzW3K+bX5aFn2dNpX2f8T75MrQwCc5Y06GI0ughKfV0
# DwO9wXqVx/kcMK0CPZC0OItd2KMMdV8JSE+2lj2VJDI43/eXDgRiTaqI689cYv9l
# mi0ewN1KwMTtAqrxPs92M4j51mADJBOVxlmbW6rdFAOf24n55dRSw4XQXtvEueIr
# xTEPUwgxkazu7mUtGCI7k2jdm4SlBoxYG53O6xrmyfnfiT0rdc/PxmUOZvRk/Cqt
# qKYJ6xff8asWoR74OQ==
# SIG # End signature block
