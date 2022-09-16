Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestContract = '1-1NC95D'
$Script:TestGroupName = 'AkamaiPowershell'
$Script:TestPropertyName = 'akamaipowershell-testing'
$Script:TestIncludeName = 'akamaipowershell-include'
$Script:AdditionalHostname = 'new.host'

Describe 'Safe PAPI Tests' {
    ### Get-AccountID
    $Script:AccountID = Get-AccountID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AccountID gets an account ID' {
        $AccountID | Should -Not -BeNullOrEmpty
    }

    ### List-Contracts
    $Script:Contracts = List-PapiContracts -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-Contracts lists contracts' {
        $Contracts[0].contractId | Should -Not -BeNullOrEmpty
    }

    $Script:Products = List-Products -ContractId $TestContract -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-Products lists products' {
        $Products.count | Should -BeGreaterThan 0
    }

    ### List-Groups
    $Script:Groups = List-Groups -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-Groups lists groups' {
        $Groups.count | Should -BeGreaterThan 0
    }

    ### Confirm Test Group exists
    $Script:TestGroup = $Groups | where {$_.groupName -eq $TestGroupName}
    it 'Test group exists' {
        $TestGroup | Should -Not -BeNullOrEmpty
        break
    }

    ### Get-Group
    $Script:GroupByID = Get-Group -GroupID $TestGroup.groupId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-Group by ID gets a group' {
        $GroupByID | Should -Not -BeNullOrEmpty
    }
    $Script:GroupByName = Get-Group -GroupName $TestGroup.groupName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-Group by name gets a group' {
        $GroupByName | Should -Not -BeNullOrEmpty
    }
    
    ### List-TopLevelGroups
    $Script:TopLevelGroups = List-TopLevelGroups -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-TopLevelGroups lists groups' {
        $TopLevelGroups[0].groupId | Should -Not -BeNullOrEmpty
    }

    ### List-PapiCPCodes
    $Script:CPCodes = List-PapiCPCodes -GroupId $TestGroup.groupId -ContractId $TestContract -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-PapiCPCodes should not be null' {
        $CPCodes | Should -Not -BeNullOrEmpty
    }

    ### Get-PapiCPCode
    $Script:CPCode = Get-PapiCPCode -CPCode $CPCodes[0].cpcodeId -GroupId $TestGroup.groupId -ContractId $TestContract -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-PapiCPCode should not be null' {
        $CPCode | Should -Not -BeNullOrEmpty
    }

    ### List-PapiEdgeHostnames
    $Script:EdgeHostnames = List-PapiEdgeHostnames -GroupId $TestGroup.groupId -ContractId $TestContract -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-PapiEdgeHostnames should not be null' {
        $EdgeHostnames | Should -Not -BeNullOrEmpty
    }

    ### Get-PapiEdgeHostname
    $Script:EdgeHostname = Get-PapiEdgeHostname -EdgeHostnameID $EdgeHostnames[0].EdgeHostnameId -GroupId $TestGroup.groupId -ContractId $TestContract -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-PapiEdgeHostname should not be null' {
        $EdgeHostname | Should -Not -BeNullOrEmpty
    }

    ### List-CustomBehaviors
    $Script:CustomBehaviors = List-CustomBehaviors -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-CustomBehaviors should not be null' {
        $CustomBehaviors | Should -Not -BeNullOrEmpty
    }

    ### Get-CustomBehaviors
    $Script:CustomBehavior = Get-CustomBehavior -BehaviorId $CustomBehaviors[0].behaviorId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-CustomBehavior should not be null' {
        $CustomBehavior | Should -Not -BeNullOrEmpty
    }

    ### Get-PapiClientSettings
    $Script:ClientSettings = Get-PAPIClientSettings -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-PapiClientSettings should not be null' {
        $ClientSettings | Should -Not -BeNullOrEmpty
    }

    ### Set-PapiClientSettings
    $Script:ClientSettings = Set-PAPIClientSettings -RuleFormat $ClientSettings.ruleFormat -UsePrefixes $ClientSettings.usePrefixes -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-PAPIClientSettings should not be null' {
        $ClientSettings | Should -Not -BeNullOrEmpty
    }
    
    ### List-Properties
    $Script:Properties = List-Properties -GroupID $TestGroup.groupId -ContractId $TestContract -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-Properties lists properties' {
        $Properties.count | Should -BeGreaterThan 0
    }

    ### Find-Property
    $Script:FoundProperty = Find-Property -PropertyName $TestPropertyName -Latest -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Find-Property finds properties' {
        $FoundProperty | Should -Not -BeNullOrEmpty
    }

    ### Get-Property by name
    $Script:Property = Get-Property -PropertyName $TestPropertyName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-Property finds properties by name' {
        $Property | Should -Not -BeNullOrEmpty
    }

    ### Get-Property by ID
    $Script:Property = Get-Property -PropertyId $FoundProperty.propertyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-Property finds properties by name' {
        $Property | Should -Not -BeNullOrEmpty
    }

    ### Get-PropertyVersion using specific
    $Script:PropertyVersion = Get-PropertyVersion -PropertyId $FoundProperty.propertyId -PropertyVersion $FoundProperty.propertyVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-PropertyVersion finds specified version' {
        $PropertyVersion | Should -Not -BeNullOrEmpty
    }

    ### Get-PropertyVersion using "latest"
    $Script:PropertyVersion = Get-PropertyVersion -PropertyId $FoundProperty.propertyId -PropertyVersion 'latest' -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-PropertyVersion finds "latest" version' {
        $PropertyVersion | Should -Not -BeNullOrEmpty
    }

    ### Get-PropertyRuleTree to variable
    $Script:Rules = Get-PropertyRuleTree -PropertyName $TestPropertyName -PropertyVersion latest -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-PropertyRuleTree returns rules object' {
        $Rules | Should -BeOfType [PSCustomObject]
        $Rules.rules | Should -Not -BeNullOrEmpty
    }

    ### Get-PropertyRuleTree to file
    Get-PropertyRuleTree -PropertyName $TestPropertyName -PropertyVersion latest -OutputToFile -OutputFileName rules.json -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-PropertyRuleTree creates json file' {
        'rules.json' | Should -Exist
    }

    <#
    ### Get-PropertyRuleTree to existing file fails
    it 'Get-PropertyRuleTree fails without -Force if file exists' {
        { Get-PropertyRuleTree -PropertyName $TestPropertyName -PropertyVersion latest -OutputToFile -OutputFileName temp.json -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Throw
    }
    #>

    ### Get-PropertyRuleTemplates
    Get-PropertyRuleTemplates -PropertyName $TestPropertyName -PropertyVersion latest -OutputDir templates -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-PropertyRuleTemplates creates expected files' {
        'templates\main.json' | Should -Exist
    }

    ### Merge-PropertyRuleTemplates creates output file
    Merge-PropertyRuleTemplates -SourceDirectory templates -OutputToFile -OutputFileName templates.json
    it 'Get-PropertyRuleTemplates creates expected files' {
        'templates.json' | Should -Exist
    }

    ### Merge-PropertyRuleTemplates creates custom object
    $Script:MergedRules = Merge-PropertyRuleTemplates -SourceDirectory templates
    it 'Merge-PropertyRuleTemplates returns rules object' {
        $MergedRules | Should -BeOfType [PSCustomObject]
        $MergedRules.rules | Should -Not -BeNullOrEmpty
    }

    ### New-PropertyVersion
    $Script:PropertyVersion = New-PropertyVersion -PropertyId $FoundProperty.propertyId -CreateFromVersion $PropertyVersion.propertyVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-PropertyVersion does not error' {
        $PropertyVersion | Should -Not -BeNullOrEmpty
    }

    ### Set-PropertyRuleTree via pipeline
    $Script:Rules = $Rules | Set-PropertyRuleTree -PropertyName $TestPropertyName -PropertyVersion latest -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-PropertyRuleTree returns rules object' {
        $Rules | Should -BeOfType PSCustomObject
        $Rules.rules | Should -Not -BeNullOrEmpty
    }

    ### List-PropertyHostnames
    $Script:PropertyHostnames = List-PropertyHostnames -PropertyName $TestPropertyName -PropertyVersion latest -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-PropertyHostnames should not be null' {
        $PropertyHostnames | Should -Not -BeNullOrEmpty
    }

    ### Set-PropertyHostnames by pipeline
    $Script:PropertyHostnames = $PropertyHostnames | Set-PropertyHostnames -PropertyName $TestPropertyName -PropertyVersion latest -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-PropertyHostnames works via pipeline' {
        $PropertyHostnames | Should -Not -BeNullOrEmpty
    }

    ### Set-PropertyHostnames by param
    $Script:PropertyHostnames = Set-PropertyHostnames -PropertyName $TestPropertyName -PropertyVersion latest -PropertyHostnames $PropertyHostnames -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-PropertyHostnames works via param' {
        $PropertyHostnames | Should -Not -BeNullOrEmpty
    }

    ### Add-PropertyHostnames via param
    $HostnameToAdd = @{ 
        cnameType = "EDGE_HOSTNAME"
        cnameFrom = $AdditionalHostname
        cnameTo = $PropertyHostnames[0].cnameTo
    }
    $Script:PropertyHostnames = Add-PropertyHostnames -PropertyName $TestPropertyName -PropertyVersion latest -NewHostnames $HostnameToAdd  -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Add-PropertyHostnames works via param' {
        $PropertyHostnames | Should -Not -BeNullOrEmpty
    }

    ### Remove-PropertyHostnames
    $Script:PropertyHostnames = Remove-PropertyHostnames -PropertyName $TestPropertyName -PropertyVersion latest -HostnamesToRemove $AdditionalHostname  -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Remove-PropertyHostnames does not error' {
        $PropertyHostnames | Should -Not -BeNullOrEmpty
    }

    ### Add-PropertyHostnames via param
    $Script:PropertyHostnames = @($HostnameToAdd) | Add-PropertyHostnames -PropertyName $TestPropertyName -PropertyVersion latest -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Add-PropertyHostnames works via pipeline' {
        $PropertyHostnames | Should -Not -BeNullOrEmpty
    }
    # Repeat removal to return hostnames to previous
    $Script:PropertyHostnames = Remove-PropertyHostnames -PropertyName $TestPropertyName -PropertyVersion latest -HostnamesToRemove $AdditionalHostname  -EdgeRCFile $EdgeRCFile -Section $Section

    ### List-RuleFormats
    $Script:RuleFormats = List-RuleFormats -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-RuleFormats returns results' {
        $RuleFormats | Should -Not -BeNullOrEmpty
    }

    ### Activate-Property
    $Script:Activation = Activate-Property -PropertyName $TestPropertyName -PropertyVersion latest -Network Staging -NotifyEmails "mail@example.com" -AcknowledgeAllWarnings -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Activate-Property returns activationlink' {
        $Activation.activationLink | Should -Not -BeNullOrEmpty
    }

    ### Get-Activation
    # Sanitise activation ID from previous response
    $Script:ActivationID = ($Activation.activationLink -split "/")[-1]
    if($ActivationID.contains("?")){
        $ActivationID = $ActivationID.Substring(0,$ActivationID.IndexOf("?"))
    }
    $Script:ActivationResult = Get-PropertyActivation -PropertyName $TestPropertyName -ActivationID $ActivationID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-Activation finds the correct activation' {
        $ActivationResult[0].activationId | Should -Be $ActivationID
    }

    #************************************************#
    #                    Includes                    #
    #************************************************#

    ### New-PropertyInclude
    $Script:NewInclude = New-PropertyInclude -IncludeName $TestIncludeName -ProductID Fresca -GroupID $TestGroup.groupId -RuleFormat v2022-06-28 -IncludeType MICROSERVICES -ContractId $TestContract -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-PropertyInclude creates an include' {
        $NewInclude.includeLink | Should -Not -BeNullOrEmpty
    }
    $NewIncludeID = $NewInclude.includeLink.Replace('/papi/v1/includes/','')
    $NewIncludeID = [int] ($NewIncludeID.SubString(0, $NewIncludeID.IndexOf('?')))

    ### List-PropertyIncludes
    $Script:Includes = List-PropertyIncludes -GroupID $TestGroup.groupId -ContractId $TestContract -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-PropertyIncludes returns a list' {
        $Includes[0].includeId | Should -Not -BeNullOrEmpty
    }

    ### Get-PropertyInclude by ID
    $Script:IncludeByID = Get-PropertyInclude -IncludeID $NewIncludeID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-PropertyInclude returns the correct data' {
        $IncludeByID.includeName | Should -Be $TestIncludeName
    }

    ### Get-PropertyInclude by name
    $Script:Include = Get-PropertyInclude -IncludeName $TestIncludeName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-PropertyInclude returns the correct data' {
        $Include.includeName | Should -Be $TestIncludeName
    }

    ### Get-PropertyIncludeRuleTree
    $Script:IncludeRules = Get-PropertyIncludeRuleTree -IncludeName $TestIncludeName -IncludeVersion 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-PropertyIncludeRuleTree returns the correct data' {
        $IncludeRules.includeName | Should -Be $TestIncludeName
    }

    ### Set-PropertyIncludeRuleTree by pipeline
    $Script:SetIncludeRulesByPipeline = ( $IncludeRules | Set-PropertyIncludeRuleTree -IncludeName $TestIncludeName -IncludeVersion 1 -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-PropertyIncludeRuleTree by pipeline updates correctly' {
        $SetIncludeRulesByPipeline.includeName | Should -Be $TestIncludeName
    }

    ### Set-PropertyIncludeRuleTree by body
    $Script:SetIncludeRulesByBody = Set-PropertyIncludeRuleTree -IncludeId $NewIncludeID -IncludeVersion 1 -Body (ConvertTo-Json $IncludeRules -Depth 100) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-PropertyIncludeRuleTree by body updates correctly' {
        $SetIncludeRulesByBody.includeName | Should -Be $TestIncludeName
    }

    ### Get-PropertyIncludeRuleTemplates
    Get-PropertyIncludeRuleTemplates -IncludeName $TestIncludeName -IncludeVersion latest -OutputDir inputtemplates -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-PropertyIncludeRuleTemplates creates expected files' {
        'inputtemplates\main.json' | Should -Exist
    }

    ### Set-PropertyIncludeRuleTemplates
    $Script:SetIncludeRulesTemplate = Set-PropertyIncludeRuleTemplates -IncludeName $TestIncludeName -IncludeVersion 1 -SourceDirectory inputtemplates -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-PropertyIncludeRuleTemplates updates successfully' {
        $SetIncludeRulesTemplate.includeName | Should -Be $TestIncludeName
    }

    ### List-PropertyIncludeVersions
    $Script:IncludeVersions = List-PropertyIncludeVersions -IncludeID $NewIncludeID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-PropertyIncludeVersions returns the correct data' {
        $IncludeVersions[0].includeVersion | Should -Not -BeNullOrEmpty
    }

    ### New-PropertyIncludeVersion
    $Script:NewIncludeVersion = New-PropertyIncludeVersion -IncludeID $NewIncludeID -CreateFromVersion 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-PropertyIncludeVersion creates a new version' {
        $NewIncludeVersion.versionLink | Should -Match $NewIncludeID
    }

    ### Remove-PropertyInclude
    $Script:RemoveInclude = Remove-PropertyInclude -IncludeID $NewIncludeID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Remove-PropertyInclude completes successfully' {
        $RemoveInclude.message | Should -Be "Deletion Successful."
    }

    AfterAll {
        ### Cleanup files
        Remove-Item rules.json -Force
        Remove-Item templates.json -Force
        Remove-Item templates -Recurse -Force
        Remove-Item inputtemplates -Recurse -Force
    }
    
}

Describe 'Unsafe PAPI Tests' {
    ### New-Property
    $Script:NewProperty = New-Property -PropertyName $TestPropertyName -ProductID Fresca -GroupID $TestGroup.groupId -ContractId $TestContract -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'New-Property creates a property' {
        $NewProperty.propertyLink | Should -Not -BeNullOrEmpty
    }

    ### Remove-Property
    $Script:RemoveProperty = Remove-Property -PropertyID 000000 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Remove-Property removes a property' {
        $RemoveProperty.message | Should -Be "Deletion Successful."
    }

    ### New-EdgeHostname
    $Script:NewEdgeHostname = New-EdgeHostname -DomainPrefix test -DomainSuffix edgesuite.net -IPVersionBehavior IPV4 -ProductId Fresca -SecureNetwork STANDARD_TLS -GroupID $TestGroup.groupId -ContractId $TestContract -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'New-Property creates a property' {
        $NewEdgeHostname.edgeHostnameLink | Should -Not -BeNullOrEmpty
    }

    ### New-CPCode
    $Script:NewCPCode = New-CPCode -CPCodeName testCP -ProductId Fresca -GroupID $TestGroup.groupId -ContractId $TestContract -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'New-Property creates a property' {
        $NewCPCode.cpcodeLink | Should -Not -BeNullOrEmpty
    }

    ### Deactivate-Property
    $Script:Deactivation = Deactivate-Property -PropertyID 123456 -PropertyVersion 1 -Network Staging -NotifyEmails "mail@example.com" -AcknowledgeAllWarnings -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Deactivate-Property returns activationlink' {
        $Deactivation.activationLink | Should -Not -BeNullOrEmpty
    }

    ### Activate-PropertyInclude
    $Script:ActivateInclude = Activate-PropertyInclude -IncludeID 123456 -IncludeVersion 1 -Network Staging -NotifyEmails 'mail@example.com' -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Activate-PropertyInclude activates successfully' {
        $ActivateInclude.activationLink | Should -Not -BeNullOrEmpty
    }

    ### Deactivate-PropertyInclude
    $Script:DeactivateInclude = Deactivate-PropertyInclude -IncludeID 123456 -IncludeVersion 1 -Network Staging -NotifyEmails 'mail@example.com' -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Deactivate-PropertyInclude activates successfully' {
        $DeactivateInclude.activationLink | Should -Not -BeNullOrEmpty
    }

    ### Get-PropertyIncludeActivation
    $Script:IncludeActivation = Get-PropertyIncludeActivation -IncludeID 123456 -ActivationID 123456789 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-PropertyIncludeActivation returns the right data' {
        $IncludeActivation.includeId | Should -Not -BeNullOrEmpty
    }

    ### List-PropertyIncludeActivations
    $Script:IncludeActivations = List-PropertyIncludeActivations -IncludeID 123456 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'List-PropertyIncludeActivations returns a list' {
        $IncludeActivations[0].includeId | Should -Not -BeNullOrEmpty
    }
}

# SIG # Begin signature block
# MIIp0gYJKoZIhvcNAQcCoIIpwzCCKb8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCLuqmTX1JXYcgj
# HEScDITpagVhj8SJZ6R9Rm6DFCJ82KCCDsEwggawMIIEmKADAgECAhAIrUCyYNKc
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
# mKw3mUwz0p7xjQIxghpnMIIaYwIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
# Ew5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBD
# b2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTECEAcizMh6w/je5qGZ
# As4SxO0wDQYJYIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
# FTAvBgkqhkiG9w0BCQQxIgQg1pTi2IYVGgEwzEcriknaT+gKri4P2jd3EGK5IveI
# bRowDQYJKoZIhvcNAQEBBQAEggIApNXgPm87EpuFzmoxiD6DI6DNj5J1MvgANsdP
# 4NGT2wXki6xL9207n6Z1kCB4ZnDpSs+3gDRk27GWfBvxifS6uuhHbOCa3Vcl+L9H
# hmJRXuF4N33eAC+qZDxMb9aWb/B43bdjPsxmyWUdhLIyBcaTBE0ETLMmXnBDTp0T
# ddGApkoaJCIHOodPcD0Xp6gR3w3OeX5HM6qtajakvh1sl3TlT2+s1igUOHLAbXKR
# +NLQjculnfpHhKxNGw0SqSlxm2+OlJ82FxhIvxSXX0GPaThGa4qdBh6/qX9FLax5
# yntIfJyKmBqaJzOKECRI7yX+KzTDEmZmFJGIGroKGdS13aq0ad8S6ePTbtXcpnwO
# DBeJCBiFXEWpriOfCYzjEVsM5mXh32AT30wVsMRQ1bgSj0ShnnRRIVu+PLedsmCG
# 1cJio/2E5JKJh2oJHkLHoNhlkewqhrGt9nr0z5ViV8AgAp1oIR9vmA8O28uh8lfP
# lpXU+NtWygDj385kB6bCTCHcD728vJdhVGDWAABBub17G6fJnlqEYmnbxGbgCEg9
# SLn+KXOPKHQU/1Vq5DVE//HP7NerxW05h0UwhC/FQNVsMcHXNswwYWcrDSMKqkTo
# TOamR3I36Zp05QKtQFvRWKp0UK5hrkAkkviIKCvdFMFhYd4Y5RIoo874Z9sbN8jk
# a8kKTnihghc9MIIXOQYKKwYBBAGCNwMDATGCFykwghclBgkqhkiG9w0BBwKgghcW
# MIIXEgIBAzEPMA0GCWCGSAFlAwQCAQUAMHcGCyqGSIb3DQEJEAEEoGgEZjBkAgEB
# BglghkgBhv1sBwEwMTANBglghkgBZQMEAgEFAAQgSfqXjUQBiqAOSB4evyBclyt/
# cE4zdHoGkZQvXESNuIgCEDXGK0bOBfDLvFoRKRwHKXAYDzIwMjIwOTE1MTg0NjQw
# WqCCEwcwggbAMIIEqKADAgECAhADyzT9Pf8SETOf8HxLIVfHMA0GCSqGSIb3DQEB
# CwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkG
# A1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3Rh
# bXBpbmcgQ0EwHhcNMjIwODMwMDAwMDAwWhcNMjMwODI5MjM1OTU5WjBGMQswCQYD
# VQQGEwJVUzERMA8GA1UEChMIRGlnaUNlcnQxJDAiBgNVBAMTG0RpZ2lDZXJ0IFRp
# bWVzdGFtcCAyMDIyIC0gMjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AM/spSY6xqnya7uNwQ2a26HoFIV0MxomrNAcVR4eNm28klUMYfSdCXc9FZYIL2tk
# pP0GgxbXkZI4HDEClvtysZc6Va8z7GGK6aYo25BjXL2JU+A6LYyHQq4mpOS7eHi5
# ehbhVsbAumRTuyoW51BIu4hpDIjG8b7gL307scpTjUCDHufLckkoHkyAHoVW54Xt
# 8mG8qjoHffarbuVm3eJc9S/tjdRNlYRo44DLannR0hCRRinrPibytIzNTLlmyLuq
# UDgN5YyUXRlav/V7QG5vFqianJVHhoV5PgxeZowaCiS+nKrSnLb3T254xCg/oxwP
# UAY3ugjZNaa1Htp4WB056PhMkRCWfk3h3cKtpX74LRsf7CtGGKMZ9jn39cFPcS6J
# AxGiS7uYv/pP5Hs27wZE5FX/NurlfDHn88JSxOYWe1p+pSVz28BqmSEtY+VZ9U0v
# kB8nt9KrFOU4ZodRCGv7U0M50GT6Vs/g9ArmFG1keLuY/ZTDcyHzL8IuINeBrNPx
# B9ThvdldS24xlCmL5kGkZZTAWOXlLimQprdhZPrZIGwYUWC6poEPCSVT8b876asH
# DmoHOWIZydaFfxPZjXnPYsXs4Xu5zGcTB5rBeO3GiMiwbjJ5xwtZg43G7vUsfHuO
# y2SJ8bHEuOdTXl9V0n0ZKVkDTvpd6kVzHIR+187i1Dp3AgMBAAGjggGLMIIBhzAO
# BgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEF
# BQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwHwYDVR0jBBgw
# FoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFGKK3tBh/I8xFO2XC809
# KpQU31KcMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5j
# cmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdD
# QS5jcnQwDQYJKoZIhvcNAQELBQADggIBAC0UyaEGSS3dimxaHgXjrMnYnjeKsKYh
# Ij9EyjE9ywwM33xT5ZRqdiX3Isk7nEIElPWCRN5u4oTo7k5EGGktx3ZsrHpzf0si
# EEmEdDfygtNBlXYxLvlZab8HVrslWfexM+66XRCFK19PgSnudu0gC3XaxWbC6eAe
# WmgBTLRktDRpqbY9fj1d6REtuXxf4RNrN0MDT+kVDdt1BVTHDTlfGDbA6HAXR1Vc
# +khF8cv4RMJ8vvP3p6z05qFttPe3RMWPCC+d8hKtJI+2C3hBwdKChzJizkfq60Vr
# qqj+dEeBnrUYhUcYIIz6WeVYk72r/31a9SowYPuTzNCktU59LF6Y2/bMPIpHeHhs
# BAvg2RMxDzH4TfzgKkGM8F8VDpTAKUXe8vlzzsNjJ4m+oeGi72Kj6if/M07iiT4k
# MEQV5Fg8BotKdIqx7a1Cf+aqpZq5+DAcFhPwo4uoKtSLAWY0aIACxRKSFqIHngiu
# c2t9n+vB/oM/rtlQNnnlt8E2hvC3yQl5+M/7sqzX4vI3BBv6ASmOsDaYOGrb90BA
# 77kpxccgavKscb/UdmJ+yGZjMyuuUzjPpKpGxMG95S9ATieDVuDFi68taSY81PJV
# mxBD/MrBbfTZ9JBLS5F1s0ecKEr6OOY1PvLIry+8TrgnFUP5KT019GjiRV2GVCOB
# x9aBB9M+oTliMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG
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
# A8s0/T3/EhEzn/B8SyFXxzANBglghkgBZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMx
# DQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTIyMDkxNTE4NDY0MFowKwYL
# KoZIhvcNAQkQAgwxHDAaMBgwFgQUXAu8gBXmzhMVxQvjwcb0K+uJlP8wLwYJKoZI
# hvcNAQkEMSIEIHJC86ULVggYi6FZDmmHee/h3HAvsvc3JgJNVKAJkWj/MDcGCyqG
# SIb3DQEJEAIvMSgwJjAkMCIEIFvV45PbHr8/M63HzaV6L1IyKAtY3e4ApXmwzqMi
# jCP/MA0GCSqGSIb3DQEBAQUABIICAANY2HUaMt9bxUcZZ+RhEf/o2XxZYFGHOVE2
# P1TGmnHTFT75FrWqORLcxwUBryg6SYVzriPuO8kKO+moQVJC6nrUFSg+PgxaNWcp
# 7uVXe9JADGTiudU/+YoF/iS8xJP3R2E7dzPRUl3PDG0VPe0UuD9+lhgIaNuz3JaX
# 5ytvG2Kmua33dsdgQH/Iu5veWmRDkUG1EEggBz2beT6scsJZ+3P5GeS6SB7tYCY2
# sDI/aasHEwY0RVhDuRfErqBu6lwlO93S2r4GbAgVOdp2OBSWBdNpAMsLs0m6rwSa
# /77U1FXItIm3I0YSJmuEH0cmHh85hjBFbec/eQcv2YmflIqJsn/QB+3jW/s8+//m
# zAOyBXClj76yfSk/aj7p92ODynry19Ke0Rs1/UykM9vFfZAnTLA4Ge+qYnkP9Eio
# nUSnAk9HPicFhzX2sbPJoc4uIUy9LtjseLAeOD9PvRvAeuyF+wOgGRU9kyWTyo4O
# sl3a1Lv50PRZ79mrc/qhvC2VESC6rHzEIhvVjrCbBO7RnsMBBkOmKV5FSENbP96G
# SwljU55aOBK2JlTM+HQPqyaGhe/PW9XTRuRhuy58sgWs7ZHiP8a7JTrDMc70yJ3/
# GX4vYTbULiaatcJV7pXicHaR3NVyFnDEF7W+h10B/dHYc039QoXhlt4Udwb1DIso
# W0+iE1AE
# SIG # End signature block
