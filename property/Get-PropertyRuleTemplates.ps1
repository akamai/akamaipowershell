<#
.SYNOPSIS
Akamai Powershell - Recursively converting rules to snippets
.DESCRIPTION
Takes a property rule tree and converts to a json, replacing with #include: statement.
.PARAMETER Rules
Rule PS object to recurse
.PARAMETER Path
Current folder path to write content to
.PARAMETER CurrentDepth
Current level of recursion. If equal or greater than MaxDept children will remain in the parent json file
.PARAMETER MaxDepth
Maximum depth as specified by the user. Allows you to limit the level of recursion and just leave children in json
.EXAMPLE
Get-ChildRuleTemplate -Rules $Rules -Path /property/offload -CurrentDepth 1 -MaxDepth 2
.LINK
developer.akamai.com
#>

function Get-ChildRuleTemplate {
    Param(
        [Parameter(Mandatory=$true)] [object] $Rules,
        [Parameter(Mandatory=$true)] [string] $Path,
        [Parameter(Mandatory=$true)] [int]    $CurrentDepth,
        [Parameter(Mandatory=$true)] [int]    $MaxDepth
    )

    $OSSlashChar = Get-OSSlashCharacter
    
    $SafeName = Sanitise-FileName -FileName $Rules.Name
    $ChildPath = "$Path$OSSlashChar$SafeName"
    $NewDepth = $CurrentDepth + 1

    if($NewDepth -lt $MaxDepth){
        if($Rules.children.count -gt 0){
            if(!(Test-Path $ChildPath)) {
                New-Item -Name $ChildPath -ItemType Directory | Out-Null
            }
        }
        for($i = 0; $i -lt $Rules.children.count; $i++) {
            Get-ChildRuleTemplate -Rules $Rules.children[$i] -Path $ChildPath -CurrentDepth $NewDepth -MaxDepth $MaxDepth
            $SafeChildName = Sanitise-FileName -FileName $Rules.children[$i].Name
            $Rules.children[$i] = "#include:$SafeName$OSSlashChar$SafeChildName.json"
        }
    }

    $Rules | ConvertTo-Json -Depth 100 | Out-File "$Path$OSSlashChar$SafeName.json"
}

<#
.SYNOPSIS
Akamai Powershell - Splitting out properties to snippets
.DESCRIPTION
Pulls a property rule tree from PAPI and breaks it down into json snippets, to a specified depth
.PARAMETER PropertyName
Property name to read from PAPI. Either this or PropertyID is required
.PARAMETER PropertyID
Property ID to read from PAPI. Either this or PropertyName is required
.PARAMETER PropertyVersion
Version of property to read from PAPI. Can be integer or 'latest'
.PARAMETER OutputDir
Folder to write snippets to. Defaults to the property name. OPTIONAL
.PARAMETER MaxDepth
Depth of recursion. Defaults to 100, which is effectively unlimited. OPTIONAL
.PARAMETER GroupID
PAPI group for the property. OPTIONAL
.PARAMETER ContractId
PAPI contract from the property. OPTIONAL
.PARAMETER EdgeRCFile
Path to .edgerc file, defaults to ~/.edgerc. OPTIONAL
.PARAMETER ContractId
.edgerc Section name. Defaults to 'default'. OPTIONAL
.PARAMETER AccountSwitchKey
Account switch key if applying to an account external to yoru API user. Only usable by Akamai staff and partners. OPTIONAL
.EXAMPLE
Get-PropertyRuleTemplates -PropertyName MyProperty -PropertyVersion latest -OutputDir MyProperty
.LINK
developer.akamai.com
#>

function Get-PropertyRuleTemplates {
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $PropertyName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $PropertyID,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$false)] [string] $OutputDir,
        [Parameter(Mandatory=$false)] [int]    $MaxDepth = 100,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

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
            if($PropertyName -eq ''){
                $Property = Find-Property -PropertyName $PropertyName -Latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            }
            $PropertyVersion = $Property.propertyVersion
        }
        catch{
            throw $_
        }
    }

    $Rules = Get-PropertyRuleTree -PropertyID $PropertyID -PropertyVersion $PropertyVersion -GroupID $GroupId -ContractId $ContractId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey

    if($OutputDir -eq ''){
        $OutputDir = $Rules.propertyName
    }
    
    # Make Property Directory if required
    if(!(Test-Path $OutputDir)) {
        Write-Host "Creating new property directory " -NoNewLine
        Write-Host -ForegroundColor Cyan $OutputDir
        New-Item -Name $OutputDir -ItemType Directory | Out-Null
    }

    for($i = 0; $i -lt $Rules.rules.children.count; $i++) {
        Get-ChildRuleTemplate -Rules $Rules.rules.children[$i] -Path $OutputDir -CurrentDepth 0 -MaxDepth $MaxDepth
        $SafeName = Sanitise-FileName -FileName $Rules.rules.children[$i].Name
        $Rules.rules.children[$i] = "#include:$SafeName.json"
    }

    ### Split variables out to its own file
    $Rules.rules.variables | ConvertTo-Json -depth 100 | Out-File "$outputdir\pmVariables.json" -Force
    $Rules.rules.variables = "#include:pmVariables.json"

    ### Write default rule to main file
    $Rules.rules | ConvertTo-Json -depth 100 | Out-File "$outputdir\main.json" -Force

    Write-Host "Wrote version " -NoNewLine
    Write-Host -ForegroundColor Cyan $Rules.propertyVersion -NoNewline
    Write-Host " of property " -NoNewline
    Write-Host  -ForegroundColor Cyan $Rules.propertyName -NoNewline
    Write-Host " to " -NoNewline
    Write-Host  -ForegroundColor Cyan $OutputDir
}

# SIG # Begin signature block
# MIIoaAYJKoZIhvcNAQcCoIIoWTCCKFUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU6/nnijnaeSwBJ4kQu7eItu2O
# j3mggiGYMIIFjTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0B
# AQwFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMjIwODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz
# 7MKnJS7JIT3yithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS
# 5F/WBTxSD1Ifxp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7
# bXHiLQwb7iDVySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfI
# SKhmV1efVFiODCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jH
# trHEtWoYOAMQjdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14
# Ztk6MUSaM0C/CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2
# h4mXaXpI8OCiEhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+wJS00mFt
# 6zPZxd9LBADMfRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPR
# iQfhvbfmQ6QYuKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ER
# ElvlEFDrMcXKchYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4K
# Jpn15GkvmB0t9dmpsh3lGwIDAQABo4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAd
# BgNVHQ4EFgQU7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SS
# y4IxLVGLp6chnfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAC
# hjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURS
# b290Q0EuY3J0MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRV
# HSAAMA0GCSqGSIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyh
# hyzshV6pGrsi+IcaaVQi7aSId229GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO
# 0Cre+i1Wz/n096wwepqLsl7Uz9FDRJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo
# 8L8vC6bp8jQ87PcDx4eo0kxAGTVGamlUsLihVo7spNU96LHc/RzY9HdaXFSMb++h
# UD38dglohJ9vytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5x
# aiNrIv8SuFQtJ37YOtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o4rmUMIIGrjCCBJag
# AwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQG
# EwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNl
# cnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIw
# MzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQg
# UlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEF
# AAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCw
# zIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8zH1ATCyZzlm34V6gCff1DtITaEfFz
# sbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ
# 7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7
# QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/teP
# c5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCY
# OjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9K
# oRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6
# dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM
# 1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbC
# dLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbEC
# AwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1N
# hS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9P
# MA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcB
# AQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggr
# BgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAI
# BgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7Zv
# mKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI
# 2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/ty
# dBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVP
# ulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAngkSumScbqyQeJsG33irr9p6xeZmB
# o1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc
# 6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3c
# HXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0d
# KNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZP
# J/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLe
# Mt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDy
# Divl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCCBrAwggSYoAMCAQICEAitQLJg0pxM
# n17Nqb2TrtkwDQYJKoZIhvcNAQEMBQAwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoT
# DERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UE
# AxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MB4XDTIxMDQyOTAwMDAwMFoXDTM2
# MDQyODIzNTk1OVowaTELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJ
# bmMuMUEwPwYDVQQDEzhEaWdpQ2VydCBUcnVzdGVkIEc0IENvZGUgU2lnbmluZyBS
# U0E0MDk2IFNIQTM4NCAyMDIxIENBMTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCC
# AgoCggIBANW0L0LQKK14t13VOVkbsYhC9TOM6z2Bl3DFu8SFJjCfpI5o2Fz16zQk
# B+FLT9N4Q/QX1x7a+dLVZxpSTw6hV/yImcGRzIEDPk1wJGSzjeIIfTR9TIBXEmtD
# mpnyxTsf8u/LR1oTpkyzASAl8xDTi7L7CPCK4J0JwGWn+piASTWHPVEZ6JAheEUu
# oZ8s4RjCGszF7pNJcEIyj/vG6hzzZWiRok1MghFIUmjeEL0UV13oGBNlxX+yT4Us
# SKRWhDXW+S6cqgAV0Tf+GgaUwnzI6hsy5srC9KejAw50pa85tqtgEuPo1rn3MeHc
# reQYoNjBI0dHs6EPbqOrbZgGgxu3amct0r1EGpIQgY+wOwnXx5syWsL/amBUi0nB
# k+3htFzgb+sm+YzVsvk4EObqzpH1vtP7b5NhNFy8k0UogzYqZihfsHPOiyYlBrKD
# 1Fz2FRlM7WLgXjPy6OjsCqewAyuRsjZ5vvetCB51pmXMu+NIUPN3kRr+21CiRshh
# WJj1fAIWPIMorTmG7NS3DVPQ+EfmdTCN7DCTdhSmW0tddGFNPxKRdt6/WMtyEClB
# 8NXFbSZ2aBFBE1ia3CYrAfSJTVnbeM+BSj5AR1/JgVBzhRAjIVlgimRUwcwhGug4
# GXxmHM14OEUwmU//Y09Mu6oNCFNBfFg9R7P6tuyMMgkCzGw8DFYRAgMBAAGjggFZ
# MIIBVTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBRoN+Drtjv4XxGG+/5h
# ewiIZfROQjAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/57qYrhwPTzAOBgNVHQ8B
# Af8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYIKwYBBQUHAQEEazBpMCQG
# CCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQQYIKwYBBQUHMAKG
# NWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290
# RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMBwGA1UdIAQVMBMwBwYFZ4EMAQMw
# CAYGZ4EMAQQBMA0GCSqGSIb3DQEBDAUAA4ICAQA6I0Q9jQh27o+8OpnTVuACGqX4
# SDTzLLbmdGb3lHKxAMqvbDAnExKekESfS/2eo3wm1Te8Ol1IbZXVP0n0J7sWgUVQ
# /Zy9toXgdn43ccsi91qqkM/1k2rj6yDR1VB5iJqKisG2vaFIGH7c2IAaERkYzWGZ
# gVb2yeN258TkG19D+D6U/3Y5PZ7Umc9K3SjrXyahlVhI1Rr+1yc//ZDRdobdHLBg
# XPMNqO7giaG9OeE4Ttpuuzad++UhU1rDyulq8aI+20O4M8hPOBSSmfXdzlRt2V0C
# FB9AM3wD4pWywiF1c1LLRtjENByipUuNzW92NyyFPxrOJukYvpAHsEN/lYgggnDw
# zMrv/Sk1XB+JOFX3N4qLCaHLC+kxGv8uGVw5ceG+nKcKBtYmZ7eS5k5f3nqsSc8u
# pHSSrds8pJyGH+PBVhsrI/+PteqIe3Br5qC6/To/RabE6BaRUotBwEiES5ZNq0RA
# 443wFSjO7fEYVgcqLxDEDAhkPDOPriiMPMuPiAsNvzv0zh57ju+168u38HcT5uco
# P6wSrqUvImxB+YJcFWbMbA7KxYbD9iYzDAdLoNMHAmpqQDBISzSoUSC7rRuFCOJZ
# DW3KBVAr6kocnqX9oKcfBnTn8tZSkP2vhUgh+Vc7tJwD7YZF9LRhbr9o4iZghurI
# r6n+lB3nYxs6hlZ4TjCCBsAwggSooAMCAQICEAxNaXJLlPo8Kko9KQeAPVowDQYJ
# KoZIhvcNAQELBQAwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJ
# bmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2
# IFRpbWVTdGFtcGluZyBDQTAeFw0yMjA5MjEwMDAwMDBaFw0zMzExMjEyMzU5NTla
# MEYxCzAJBgNVBAYTAlVTMREwDwYDVQQKEwhEaWdpQ2VydDEkMCIGA1UEAxMbRGln
# aUNlcnQgVGltZXN0YW1wIDIwMjIgLSAyMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
# MIICCgKCAgEAz+ylJjrGqfJru43BDZrboegUhXQzGias0BxVHh42bbySVQxh9J0J
# dz0Vlggva2Sk/QaDFteRkjgcMQKW+3KxlzpVrzPsYYrppijbkGNcvYlT4DotjIdC
# riak5Lt4eLl6FuFWxsC6ZFO7KhbnUEi7iGkMiMbxvuAvfTuxylONQIMe58tySSge
# TIAehVbnhe3yYbyqOgd99qtu5Wbd4lz1L+2N1E2VhGjjgMtqedHSEJFGKes+JvK0
# jM1MuWbIu6pQOA3ljJRdGVq/9XtAbm8WqJqclUeGhXk+DF5mjBoKJL6cqtKctvdP
# bnjEKD+jHA9QBje6CNk1prUe2nhYHTno+EyREJZ+TeHdwq2lfvgtGx/sK0YYoxn2
# Off1wU9xLokDEaJLu5i/+k/kezbvBkTkVf826uV8MefzwlLE5hZ7Wn6lJXPbwGqZ
# IS1j5Vn1TS+QHye30qsU5Thmh1EIa/tTQznQZPpWz+D0CuYUbWR4u5j9lMNzIfMv
# wi4g14Gs0/EH1OG92V1LbjGUKYvmQaRllMBY5eUuKZCmt2Fk+tkgbBhRYLqmgQ8J
# JVPxvzvpqwcOagc5YhnJ1oV/E9mNec9ixezhe7nMZxMHmsF47caIyLBuMnnHC1mD
# jcbu9Sx8e47LZInxscS451NeX1XSfRkpWQNO+l3qRXMchH7XzuLUOncCAwEAAaOC
# AYswggGHMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQM
# MAoGCCsGAQUFBwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAf
# BgNVHSMEGDAWgBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUYore0GH8
# jzEU7ZcLzT0qlBTfUpwwWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFt
# cGluZ0NBLmNybDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6
# Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVT
# dGFtcGluZ0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAVaoqGvNG83hXNzD8deNP
# 1oUj8fz5lTmbJeb3coqYw3fUZPwV+zbCSVEseIhjVQlGOQD8adTKmyn7oz/AyQCb
# Ex2wmIncePLNfIXNU52vYuJhZqMUKkWHSphCK1D8G7WeCDAJ+uQt1wmJefkJ5ojO
# fRu4aqKbwVNgCeijuJ3XrR8cuOyYQfD2DoD75P/fnRCn6wC6X0qPGjpStOq/CUkV
# NTZZmg9U0rIbf35eCa12VIp0bcrSBWcrduv/mLImlTgZiEQU5QpZomvnIj5EIdI/
# HMCb7XxIstiSDJFPPGaUr10CU+ue4p7k0x+GAWScAMLpWnR1DT3heYi/HAGXyRkj
# gNc2Wl+WFrFjDMZGQDvOXTXUWT5Dmhiuw8nLw/ubE19qtcfg8wXDWd8nYiveQclT
# uf80EGf2JjKYe/5cQpSBlIKdrAqLxksVStOYkEVgM4DgI974A6T2RUflzrgDQkfo
# QTZxd639ouiXdE4u2h4djFrIHprVwvDGIqhPm73YHJpRxC+a9l+nJ5e6li6FV8Bg
# 53hWf2rvwpWaSxECyIKcyRoFfLpxtU56mWz06J7UWpjIn7+NuxhcQ/XQKujiYu54
# BNu90ftbCqhwfvCXhHjjCANdRyxjqCU4lwHSPzra5eX25pvcfizM/xdMTQCi2NYB
# DriL7ubgclWJLCcZYfZ3AYwwggfZMIIFwaADAgECAhAJi6B8zycIi8m1Q3xkIZDn
# MA0GCSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2Vy
# dCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25p
# bmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjMwMTExMDAwMDAwWhcNMjMw
# MzAxMjM1OTU5WjCB3jETMBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8
# AgECEwhEZWxhd2FyZTEdMBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEDAO
# BgNVBAUTBzI5MzM2MzcxCzAJBgNVBAYTAlVTMRYwFAYDVQQIEw1NYXNzYWNodXNl
# dHRzMRIwEAYDVQQHEwlDYW1icmlkZ2UxIDAeBgNVBAoTF0FrYW1haSBUZWNobm9s
# b2dpZXMgSW5jMSAwHgYDVQQDExdBa2FtYWkgVGVjaG5vbG9naWVzIEluYzCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALFDEw1oBMbHbJBtOuHBaSg6zH1h
# MhdPWEtWOgnEO7TgO6LGXoRuP6gZmX844/W6kH+CRIMAzei+6AQ2AUzOAWH7ipwS
# cikJHPmxUWM/+yNWJLrnZtgOtPJalsqm3oTjCF/+WDGEVul5EMhlKb6WIg50gzWr
# 3HbG0ym564cdqZQJtn1k6m13FNtIIykgDuR9ttFdh1tsBBYOrSP6W1uu+NNpDBwr
# 16njSQtmqZTwgO+VZT/dNRvalW1a4vlAgN+U/Xo72aNqIiVnByFP2Gj6IWbUezNj
# gOFMkSe7u52cVu51GfL2XjKWup0X0gfluU06P3QZN+wiZFBfsdmXiGAXPd+UysAG
# Uh1XJ+2lnVQyHD9L1Qmw11wWD/pNYQIvjWdpzxU5NdaXEH/lbBouF+94C8HI74ty
# zsSW/E9mb+enLAebUp4jemguKMhsZC3WG2PhqlIdvPDWmaGmg6td5flco4W9xUkg
# f8LpgYrCUaqWwQ/JXht0dl4ITqgJwHorK4MT2B3X0Ft+/cTHLxSBm8TcggwTEPXQ
# HCiZjbxuHNvAZQga7+0NC4cljUhbCbhLTe7gX+XAq9LwcAtlSzN/aVF6tpPMyCj/
# xuFCBjWtML079FoIST69sVfhdjFYUfS1goauFy+CqXda3Rgirv48tm11MmpgJf5u
# zFy9+sdRhWzLC66pAgMBAAGjggIFMIICATAfBgNVHSMEGDAWgBRoN+Drtjv4XxGG
# +/5hewiIZfROQjAdBgNVHQ4EFgQULvUKZAEQ6oPpuyNAwiZsQgGlULIwDgYDVR0P
# AQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMIG1BgNVHR8Ega0wgaowU6BR
# oE+GTWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENv
# ZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3JsMFOgUaBPhk1odHRwOi8v
# Y3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JT
# QTQwOTZTSEEzODQyMDIxQ0ExLmNybDA9BgNVHSAENjA0MDIGBWeBDAEDMCkwJwYI
# KwYBBQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCBlAYIKwYBBQUH
# AQEEgYcwgYQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBc
# BggrBgEFBQcwAoZQaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# VHJ1c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcnQwDAYD
# VR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAulx9aewYZWl0UyqeAts4V+P0
# 6gcLf+4Hsnwtn8hAlqT8o+8hnPB5LplZCR3OJT98gIq6dXAvPQJWNq1pc/RD0OTI
# pEDsmqzw0c/OHPrnZcuxQxHojQe2J2Gx9E5u6AobLHFTz1+kmgQzRGyCMBecdPRW
# ubXxTyL9SiHE2XN/oXZMBWQdmpl3a79wia495lO2rstz/VNCjX0Hc5FOo+ewExly
# 4WfPqYmAVH1cJ3AKrh79dFJhgaeLd/+3szgImHJ8C7EsvobpwKPW9JGbNf6QnvQ/
# ZbTNdqAzedwtAziNw0F26+EKuf2P2VVBIHiepF51Dh+wSo8qA+A9NFxMb17zMXnN
# x8XcQd/dAULN3X7XT3J3OaSvxMKTMcboh0r5T3OLTy61KYGBa4UCYuVPrMCv0Lji
# vCdqVRfWlZNTrsD0dOIUtpjrK/JLxpwRx0I50QQMsPzs5BJLHS+3ULv82xftwwfM
# bbLBZicDSmLRN0HVzY0hfxTRwRJAKYmCdhSfH/IcwuKyn4kGeXIkaEtGYAhDvLfy
# xjXDd5VcQeScaq7x+EXW5wgISNwxf2kUFgthzEvDNObsnQ3Lr9TwPy/+5Lkj1Oa5
# Q2CEnALMLhFL55Cz7xHggTSuzdnNLmJPMXj0XwVbDITd0lVjQ9Vn7WNa4U38vn6X
# jw+A6gdW445gtFLdy/4xggY6MIIGNgIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYD
# VQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBH
# NCBDb2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTECEAmLoHzPJwiL
# ybVDfGQhkOcwCQYFKw4DAhoFAKBwMBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3
# DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEV
# MCMGCSqGSIb3DQEJBDEWBBSEgvYct6mxz54Op9oG6dQoPVgj+TANBgkqhkiG9w0B
# AQEFAASCAgBMYS9iHe3rqTUdkuIU9XIVIjrGhKCn4/jH4HO1MNxKMryBntYn1Noc
# OlIx/3MyGQ08a2UbiyocS6RJmFOAs0cCB9yxbW0SogX32sB2JfAqLSTLUDIiZbR5
# +utq9760kYQJXpw5cw2D3AHFh8ZhLxxyHCH17HEMyETDLMh2gmRelHivejNaWnQF
# RPvcfH9qfmi2XYALMMdKDSAwBRuw6vT6mLS69XpUwHcQ8YYU+juBVWp6OSWrgmqA
# 76A+qX2Dgvu63Ickw1zCkkhUJI8YJd+3qgRrxfntanVUTWGLxa5Whkm43d/Av2bJ
# rrxNOSdD8pYG/jtpsZnx8hO0fBdGkf7oVEv7elClTRDgQxaUVh0nGeXd5Vq6epoC
# RZLMEL2xUzjbkwOY+wXpJqd5/dIMu37OFdamw56g8j0UsPDH0LPVgvShJ3jdsqbO
# LpdmYSwkl5jVnperUrV76VwC7HHHCZmdsHCypB4xvk/zOu1aK9+dq1kqY2ENfORq
# LZ4sD4wh0V9T8PnI9YFg1WS3B9rzEv1LxraEuaLm70jnyCSLIyuRr8FUVkRy2fNs
# 5em72J39KjyiaKR96+JATOeF5asVHxYhJnKyxjgwT+fbWCHIOJE7PxGfbNHasJ+B
# xje5oSLYH115lrimLnpDFu8ylxE76C9a8Fe20lHl4ZTG/HQ3TxQtUKGCAyAwggMc
# BgkqhkiG9w0BCQYxggMNMIIDCQIBATB3MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
# Ew5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBS
# U0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAxNaXJLlPo8Kko9KQeAPVow
# DQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqG
# SIb3DQEJBTEPFw0yMzAyMjcxNjMxMzVaMC8GCSqGSIb3DQEJBDEiBCDa33xNv8xT
# Ym/gvbe1XTEo0jeLYXhmuo3LLbnUypgCYzANBgkqhkiG9w0BAQEFAASCAgCpz546
# 0Yd29UqTv3+ErI0fQxUXNkQnAVWpIGFTqRWMZDLrULZ+RbMv7ZPebN9suBhksI5P
# XVXv4Z78m/yTva6OvCsdDvQPjMXPW7El7+KF7yZD0SI0+g5hVXJjJTJjieQf5rFQ
# r3uM+3lA87KHRxXKpIZw3tsaqEOuMJsRdGKM5c4GH6SXMsmmpyDFmYhD0SHAsxqn
# R7ym+aQ8L8UZhuikBe08YBV7yYC90Q2ajLdW1rlvtpn8gz+VR7/0LadaemN73J7R
# 8cSJEytIrV+oDQrzuoG1vEFDsOIe3P665c9LREwh8NHO/rr5U6X+dCnIJ8CZi2iT
# SXYaLR1Dt5qDjNtuftRJRrn1ZOlyNzuJTCh1tg+L/npf0bugM19diVIr9iGQbAnm
# W6Z34l71yVGtuS102DS0akP5alviRN9fFkIHvvai+pg6TMmUfJrQTuBcua+WDT2J
# +/Jkh3WoCrEZtUoi/hurayoRDx1O1H+ikhF9/2lw66McCQ0eZtm0YuFCzB5o0gD/
# TkYUmh0gHA4V/mw6BlLoRcLuYgB+kQb7qK8NtsWXmCvn1Jaxe009F988iGXXWOSI
# YectYneIyYcNxk3E4AnjYn1umoxEG1b1VOl5CByzRyk6YyjkCTSMbHN/lT6K7Jyo
# w2uihSgYMN8vyH7zE138rA2jForqAk09PhqffQ==
# SIG # End signature block
