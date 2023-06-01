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
$Script:TestBucketPropertyName = 'akamaipowershell-bucket'

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
    $Script:TestGroup = $Groups | Where-Object { $_.groupName -eq $TestGroupName }
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
    Get-PropertyRuleTemplates -PropertyId $FoundProperty.propertyId -PropertyVersion latest -OutputDir templates -EdgeRCFile $EdgeRCFile -Section $Section
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
        cnameTo   = $PropertyHostnames[0].cnameTo
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
    $Script:Activation = Activate-Property -PropertyName $TestPropertyName -PropertyVersion latest -Network Staging -NotifyEmails "mail@example.com" -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Activate-Property returns activationlink' {
        $Activation.activationLink | Should -Not -BeNullOrEmpty
    }

    ### Get-PropertyActivation
    # Sanitize activation ID from previous response
    $Script:ActivationID = ($Activation.activationLink -split "/")[-1]
    if ($ActivationID.contains("?")) {
        $ActivationID = $ActivationID.Substring(0, $ActivationID.IndexOf("?"))
    }
    $Script:ActivationResult = Get-PropertyActivation -PropertyName $TestPropertyName -ActivationID $ActivationID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-Activation finds the correct activation' {
        $ActivationResult[0].activationId | Should -Be $ActivationID
    }

    ### List-PropertyActivations
    $Script:Activations = List-PropertyActivations -PropertyName $TestPropertyName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-PropertyActivations returns a list' {
        $Activations.count | Should -Not -Be 0
    }

    #************************************************#
    #                    Includes                    #
    #************************************************#

    ### New-PropertyInclude
    $Script:NewInclude = New-PropertyInclude -IncludeName $TestIncludeName -ProductID Fresca -GroupID $TestGroup.groupId -RuleFormat v2022-06-28 -IncludeType MICROSERVICES -ContractId $TestContract -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-PropertyInclude creates an include' {
        $NewInclude.includeLink | Should -Not -BeNullOrEmpty
    }
    $NewIncludeID = $NewInclude.includeLink.Replace('/papi/v1/includes/', '')
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

    #************************************************#
    #                Hostname Buckets                #
    #************************************************#

    ### List-BucketActivations
    $Script:BucketActivations = List-BucketActivations -PropertyName $TestBucketPropertyName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-BucketActivations returns a list' {
        $BucketActivations[0].hostnameActivationId | Should -Not -BeNullOrEmpty
    }

    ### Get-BucketActivation
    $Script:BucketActivation = Get-BucketActivation -PropertyName $TestBucketPropertyName -ActivationID $BucketActivations[0].hostnameActivationId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-BucketActivation returns the correct data' {
        $BucketActivation.hostnameActivationId | Should -Be $BucketActivations[0].hostnameActivationId
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
    $Script:Deactivation = Deactivate-Property -PropertyID 123456 -PropertyVersion 1 -Network Staging -NotifyEmails "mail@example.com" -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Deactivate-Property returns activationlink' {
        $Deactivation.activationLink | Should -Not -BeNullOrEmpty
    }

    #************************************************#
    #                    Includes                    #
    #************************************************#

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

    #************************************************#
    #                Hostname Buckets                #
    #************************************************#

    ### Add-BucketHostnames
    $BucketHostnameToAdd = @{ 
        cnameType            = "EDGE_HOSTNAME"
        cnameFrom            = $AdditionalHostname
        cnameTo              = $PropertyHostnames[0].cnameTo
        edgeHostnameId       = $PropertyHostnames[0].edgeHostnameId
        certProvisioningType = 'CPS_MANAGED'
    }
    $Script:AddBucketHostnames = Add-BucketHostnames -PropertyID 123456 -Network STAGING -NewHostnames $BucketHostnameToAdd -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Add-BucketHostnames returns the correct data' {
        $AddBucketHostnames[0].cnameFrom | Should -Not -BeNullOrEmpty
    }

    ### List-BucketHostnames
    $Script:BucketHostnames = List-BucketHostnames -PropertyID 123456 -Network STAGING -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'List-BucketHostnames returns a list' {
        $BucketHostnames[0].cnameFrom | Should -Not -BeNullOrEmpty
    }

    ### Compare-BucketHostnames
    $Script:BucketComparison = Compare-BucketHostnames -PropertyID 123456 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Compare-BucketHostnames returns the correct data' {
        $BucketComparison[0].cnameFrom | Should -Not -BeNullOrEmpty
    }

    ### Remove-BucketHostnames
    $Script:RemoveBucketHostnames = Remove-BucketHostnames -PropertyID 123456 -Network STAGING -HostnamesToRemove $AdditionalHostname -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Remove-BucketHostnames returns the correct data' {
        $RemoveBucketHostnames[0].cnameFrom | Should -Not -BeNullOrEmpty
    }

    ### Remove-BucketActivation
    $Script:BucketActivationCancellation = Remove-BucketActivation -PropertyID 123456 -ActivationID 987654 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Remove-BucketActivation returns the correct data' {
        $BucketActivationCancellation.hostnameActivationId | Should -Not -BeNullOrEmpty
    }
}

# SIG # Begin signature block
# MIIpogYJKoZIhvcNAQcCoIIpkzCCKY8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCD5bLGZYnC81NVP
# xK49L1f164jAPFFrfeA2iuQQDxWEuqCCDpEwggawMIIEmKADAgECAhAIrUCyYNKc
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
# JZzQBtUCg02o9ogxghpnMIIaYwIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
# Ew5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBD
# b2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTECEAfNhs90vQbgM/Sa
# PxCFDBcwDQYJYIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
# FTAvBgkqhkiG9w0BCQQxIgQgJDE0/R6U/mKErNbeI3wXKqXgOn3N4JnwNsuY6bGY
# W9swDQYJKoZIhvcNAQEBBQAEggIAIBvCnxpWkFEO1FXUg4sOzby1zVUuHKslqQdw
# t10dJx8x/CIkLwWILRyHYfHjWy4FDlVjQNJGB29gXVUUq2oGwYyFYpwgzAgQqIHw
# HJsCWWEEaZUG1cGtVpCmPtVkCawMWfYQbWhmBC9H+ZxjD6dB/7XrVgEMsry/zBTq
# UQI1Ytxr6g0VI6lnSG16qXm+v5rQGzGa12IQ5o9yz/0LbCrM9GZB+BodsOKBVWBI
# TGO5pyUnO7leSlzRtlZdfr+yAb7VfjGMoLUnJeyJfMWiaptijYHNvLWSVOFfplxj
# 8o/y0+yI7NZFvWaQTTxadK1vXdtyWWWqy8PUFzRNX4u5og+KlIxHVUGSiicORT+Q
# 65rdMel3E71anCmFLb1TE2t4/b2n2Y2fi1lrkd3ZxM+Puns31dThuvpjhdO0yS4t
# sUHKYZ2eSo76PdnLdPPU48LgxRt8aeEyda0PW7IZfyM6J1bxJVIOnoaQ0+GD6+bW
# HTQzZNCKB2RZ7L+p8PDa5o508FgtcdUB6QYFt1e1RbLdY7kn2KuWw18Hi3nNu/Ca
# SPjLykZET+E9KT73X/LzHjncV602Bm+l99sk7eFVM2ef4OrVFILhFGRg5/0OHWW7
# a3U5+4+v0LiMM8ROMJSrrPCKydmFXgmxDvXivLqs86GwYQTmpECcdKAtvKS6tOSM
# 5+oyGwehghc9MIIXOQYKKwYBBAGCNwMDATGCFykwghclBgkqhkiG9w0BBwKgghcW
# MIIXEgIBAzEPMA0GCWCGSAFlAwQCAQUAMHcGCyqGSIb3DQEJEAEEoGgEZjBkAgEB
# BglghkgBhv1sBwEwMTANBglghkgBZQMEAgEFAAQgKdRoqkjVLh+FyNpvdIyTYNpf
# rFN1VHcTaJTgQDJUtMUCECVqGnXKOgGK6EWUqteHsq4YDzIwMjMwNDI1MTcxNjAw
# WqCCEwcwggbAMIIEqKADAgECAhAMTWlyS5T6PCpKPSkHgD1aMA0GCSqGSIb3DQEB
# CwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkG
# A1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3Rh
# bXBpbmcgQ0EwHhcNMjIwOTIxMDAwMDAwWhcNMzMxMTIxMjM1OTU5WjBGMQswCQYD
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
# QS5jcnQwDQYJKoZIhvcNAQELBQADggIBAFWqKhrzRvN4Vzcw/HXjT9aFI/H8+ZU5
# myXm93KKmMN31GT8Ffs2wklRLHiIY1UJRjkA/GnUypsp+6M/wMkAmxMdsJiJ3Hjy
# zXyFzVOdr2LiYWajFCpFh0qYQitQ/Bu1nggwCfrkLdcJiXn5CeaIzn0buGqim8FT
# YAnoo7id160fHLjsmEHw9g6A++T/350Qp+sAul9Kjxo6UrTqvwlJFTU2WZoPVNKy
# G39+XgmtdlSKdG3K0gVnK3br/5iyJpU4GYhEFOUKWaJr5yI+RCHSPxzAm+18SLLY
# kgyRTzxmlK9dAlPrnuKe5NMfhgFknADC6Vp0dQ094XmIvxwBl8kZI4DXNlpflhax
# YwzGRkA7zl011Fk+Q5oYrsPJy8P7mxNfarXH4PMFw1nfJ2Ir3kHJU7n/NBBn9iYy
# mHv+XEKUgZSCnawKi8ZLFUrTmJBFYDOA4CPe+AOk9kVH5c64A0JH6EE2cXet/aLo
# l3ROLtoeHYxayB6a1cLwxiKoT5u92ByaUcQvmvZfpyeXupYuhVfAYOd4Vn9q78KV
# mksRAsiCnMkaBXy6cbVOepls9Oie1FqYyJ+/jbsYXEP10Cro4mLueATbvdH7Wwqo
# cH7wl4R44wgDXUcsY6glOJcB0j862uXl9uab3H4szP8XTE0AotjWAQ64i+7m4HJV
# iSwnGWH2dwGMMIIGrjCCBJagAwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG
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
# DE1pckuU+jwqSj0pB4A9WjANBglghkgBZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMx
# DQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTIzMDQyNTE3MTYwMFowKwYL
# KoZIhvcNAQkQAgwxHDAaMBgwFgQU84ciTYYzgpI1qZS8vY+W6f4cfHMwLwYJKoZI
# hvcNAQkEMSIEICK1sEHoK2YUZznA4LvwBQ8Yuk/To5qyIBuGnMyC8sBGMDcGCyqG
# SIb3DQEJEAIvMSgwJjAkMCIEIMf04b4yKIkgq+ImOr4axPxP5ngcLWTQTIB1V6Aj
# tbb6MA0GCSqGSIb3DQEBAQUABIICADld5sIGGl8DqVIy9+4Yr1dDkpAqGjdtOhJl
# T/Gsudehy+yMo7Bg+vKmJXqgTJwyFPHM4SEptOhgH+lDSLE7sF6wKFBuma2QYAEq
# EZzaglsiZ6LledSbflhWB0YOWQlwnk+87pQmBNFgfaUnU7j5YlsmVGz4Yevwnqlz
# RY3jk1owJHAGeVHwAOmhnxKIHOjSjrBxC2cn+8WbFPaMXnzk8ppSd4lSIaukU3zn
# oyym03IvMtPlf5fmuph3/qtB3xX/+MdL9n1WW/yMOfJ7tywZvT/YEbG8YxgTIxfE
# Tw23N7seLq8hdHRZM+PppT5euqKTV5a0o0/FHQ2mh1M5f/1cKfTCDGjICYBTlpBX
# ye898TtFO2Wl2T2Nuq6i27fzxja23NOiYmYx2Yn37uUL+Rh5vm61QKWpLpCAwIb4
# WKurEE/uOcJUBBIgDuqLsoBXeMHUAWyhFxS+iCyZ4d5iAf/0YDqdPjQ8oCcvBYQv
# smGERBaLvlSevBhMPg2lm/DzyakUHm7qYgJkcgdQmKDlYVdl4wgNimzAVT42lJhC
# +VYodzctEjStyCyvAWaidwJ9CXfJ9qbYx570QrQNL4HR9cUA4VaeYEzSqa7Ot1TR
# J9lL9HIxPw73E2D3LHXy2TtC4YIa7bWpfVigwLCwhqeFjFF+LQqrgjW2S3us8Nos
# MBYuWFSz
# SIG # End signature block
