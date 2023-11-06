Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestContract = '1-1NC95D'
$Script:TestGroupName = 'AkamaiPowershell'
$Script:TestPropertyName = 'akamaipowershell-testing'
$Script:TestHostname = 'akamaipowershell-testing.edgesuite.net'
$Script:TestIncludeName = 'akamaipowershell-include'
$Script:AdditionalHostname = 'new.host'
$Script:TestBucketPropertyName = 'akamaipowershell-bucket'

Describe 'Safe PAPI Tests' {
    ### Get-AccountID
    $Script:AccountID = Get-AccountID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AccountID gets an account ID' {
        $AccountID | Should -Not -BeNullOrEmpty
    }
    
    ### Get-AccountHostnames
    $Script:AccountHostnames = Get-AccountHostnames -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AccountHostnames returns a list' {
        $AccountHostnames.count | Should -Not -BeNullOrEmpty
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
    
    ### Get-HostnameAuditHistory
    $Script:AuditHistory = Get-HostnameAuditHistory -Hostname $TestHostname -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-HostnameAuditHistory returns the correct data' {
        $AuditHistory[0].cnameTo | Should -Not -BeNullOrEmpty
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
# MIIpoQYJKoZIhvcNAQcCoIIpkjCCKY4CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAJP38E4BPcIWa9
# 42pjexdJqFygkYfStWZOWfxxLszXXaCCDo4wggawMIIEmKADAgECAhAIrUCyYNKc
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
# moABt8TK7rsxghppMIIaZQIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5E
# aWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2Rl
# IFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTECEAHJkf0nnQCyP+gcdt4d
# yXMwDQYJYIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAv
# BgkqhkiG9w0BCQQxIgQgBLdZBlb0NHB5VdXvUWIdRUMVXuamHV45cpXT5N81398w
# DQYJKoZIhvcNAQEBBQAEggIAuZdg4bDnz+pYUQep6sAvwr0SpDez1D8wEDRbq3sl
# VKRC/MLk8E3kxgdiOla1x5qrwxbd6mA9TWkXOnKeFl5FMlqluX8oUaC13BS7e4cS
# /j63kU549yHEuZs0bpMDfkO/2x0KkMh4apBkPlVpHNmRzlav7OI23QJS5OwRlg9+
# 2Owdlu3M9ZDF6jhTgvTjBe0XmwYLh3cv4GPeG+yHuBrOlHoEZ9PG1PEdEiwYol1o
# 2IHACb6c1oH/wM6jnzcrF9kb3Uw9Hcu4mDmnvrKajwI71jFwwX+3/qCv701At3Ta
# pfnZfOfInXAmxLw4b55lbJYqA6sjG+BVSd+e3DrLxW2j8jKO/P00y3WcrSL0zQg7
# Z3AKRiliO0wOcgN8aCiPsur5x0anz20mdWZ8RRGQKZ1v9737czVSo2pZF0ozsEJ/
# 2uJHUJvWcvgWM1NqHMEtaqj3RcV8aAG4yT5MyaJzqIk0MMib91az5P/4WvnresNQ
# L3DU8E/4gTae9G6hC/CKvAsNq5sCRb4iC9m8Z2L3PwxLjCmuXVX2vA5YXDXM0RxA
# bxWpyZ0KQu7eQ8+awG2mPVfIrKTjHa0TwO+Rtv0SYj65cnxg1I2ciMPKsGoX3Sl+
# 8rB+gyBKzHtSdcP7hVQryOF9C1+rPs71mOk3B79WBDlkvdLaL+EnIh7kOfINq2GX
# DaGhghc/MIIXOwYKKwYBBAGCNwMDATGCFyswghcnBgkqhkiG9w0BBwKgghcYMIIX
# FAIBAzEPMA0GCWCGSAFlAwQCAQUAMHcGCyqGSIb3DQEJEAEEoGgEZjBkAgEBBglg
# hkgBhv1sBwEwMTANBglghkgBZQMEAgEFAAQgm9uU2tGlYh5bYKiwa+qs8zOVszty
# It17qZpJwPCHxy4CEGiycTVgcUPtO7Gn2bUN+80YDzIwMjMxMTA2MTcxMTU0WqCC
# EwkwggbCMIIEqqADAgECAhAFRK/zlJ0IOaa/2z9f5WEWMA0GCSqGSIb3DQEBCwUA
# MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UE
# AxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBp
# bmcgQ0EwHhcNMjMwNzE0MDAwMDAwWhcNMzQxMDEzMjM1OTU5WjBIMQswCQYDVQQG
# EwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xIDAeBgNVBAMTF0RpZ2lDZXJ0
# IFRpbWVzdGFtcCAyMDIzMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# o1NFhx2DjlusPlSzI+DPn9fl0uddoQ4J3C9Io5d6OyqcZ9xiFVjBqZMRp82qsmrd
# ECmKHmJjadNYnDVxvzqX65RQjxwg6seaOy+WZuNp52n+W8PWKyAcwZeUtKVQgfLP
# ywemMGjKg0La/H8JJJSkghraarrYO8pd3hkYhftF6g1hbJ3+cV7EBpo88MUueQ8b
# ZlLjyNY+X9pD04T10Mf2SC1eRXWWdf7dEKEbg8G45lKVtUfXeCk5a+B4WZfjRCtK
# 1ZXO7wgX6oJkTf8j48qG7rSkIWRw69XloNpjsy7pBe6q9iT1HbybHLK3X9/w7nZ9
# MZllR1WdSiQvrCuXvp/k/XtzPjLuUjT71Lvr1KAsNJvj3m5kGQc3AZEPHLVRzapM
# ZoOIaGK7vEEbeBlt5NkP4FhB+9ixLOFRr7StFQYU6mIIE9NpHnxkTZ0P387RXoyq
# q1AVybPKvNfEO2hEo6U7Qv1zfe7dCv95NBB+plwKWEwAPoVpdceDZNZ1zY8Sdlal
# JPrXxGshuugfNJgvOuprAbD3+yqG7HtSOKmYCaFxsmxxrz64b5bV4RAT/mFHCoz+
# 8LbH1cfebCTwv0KCyqBxPZySkwS0aXAnDU+3tTbRyV8IpHCj7ArxES5k4MsiK8rx
# KBMhSVF+BmbTO77665E42FEHypS34lCh8zrTioPLQHsCAwEAAaOCAYswggGHMA4G
# A1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUF
# BwMIMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAfBgNVHSMEGDAW
# gBS6FtltTYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUpbbvE+fvzdBkodVWqWUx
# o97V40kwWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNy
# bDCBkAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRp
# Z2ljZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NB
# LmNydDANBgkqhkiG9w0BAQsFAAOCAgEAgRrW3qCptZgXvHCNT4o8aJzYJf/LLOTN
# 6l0ikuyMIgKpuM+AqNnn48XtJoKKcS8Y3U623mzX4WCcK+3tPUiOuGu6fF29wmE3
# aEl3o+uQqhLXJ4Xzjh6S2sJAOJ9dyKAuJXglnSoFeoQpmLZXeY/bJlYrsPOnvTcM
# 2Jh2T1a5UsK2nTipgedtQVyMadG5K8TGe8+c+njikxp2oml101DkRBK+IA2eqUTQ
# +OVJdwhaIcW0z5iVGlS6ubzBaRm6zxbygzc0brBBJt3eWpdPM43UjXd9dUWhpVgm
# agNF3tlQtVCMr1a9TMXhRsUo063nQwBw3syYnhmJA+rUkTfvTVLzyWAhxFZH7doR
# S4wyw4jmWOK22z75X7BC1o/jF5HRqsBV44a/rCcsQdCaM0qoNtS5cpZ+l3k4SF/K
# wtw9Mt911jZnWon49qfH5U81PAC9vpwqbHkB3NpE5jreODsHXjlY9HxzMVWggBHL
# FAx+rrz+pOt5Zapo1iLKO+uagjVXKBbLafIymrLS2Dq4sUaGa7oX/cR3bBVsrquv
# czroSUa31X/MtjjA2Owc9bahuEMs305MfR5ocMB3CtQC4Fxguyj/OOVSWtasFyIj
# TvTs0xf7UGv/B3cfcZdEQcm4RtNsMnxYL2dHZeUbc7aZ+WssBkbvQR7w8F/g29mt
# kIBEr4AQQYowggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqGSIb3
# DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAX
# BgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0
# ZWQgUm9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMxCzAJ
# BgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGln
# aUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0Ew
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXHJQPE
# 8pE3qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMfUBML
# JnOWbfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w1lbU
# 5ygt69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRktFLy
# dkf3YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYbqMFk
# dECnwHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yemj052FVUmcJgm
# f6AaRyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP65x9a
# bJTyUpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzKQtwY
# SH8UNM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo80Vg
# vCONWPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjBJgj5
# FBASA31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXcheMBK9
# Rp6103a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAdBgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU7Nfj
# gtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsG
# AQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29jc3Au
# ZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdpY2Vy
# dC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDigNqA0
# hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0
# LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZIhvcN
# AQELBQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd4ksp
# +3CKDaopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiCqBa9
# qVbPFXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl/Yy8
# ZCaHbJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeCRK6Z
# JxurJB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYTgAnE
# tp/Nh4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/a6fx
# ZsNBzU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37xJV7
# 7QpfMzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmLNriT
# 1ObyF5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0YgkP
# Cr2B2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJRyvm
# fxqkhQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIFjTCC
# BHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0BAQwFADBlMQswCQYD
# VQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGln
# aWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0Ew
# HhcNMjIwODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYDVQQGEwJVUzEV
# MBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29t
# MSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIiMA0GCSqGSIb3
# DQEBAQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKnJS7JIT3yithZ
# wuEppz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/WBTxSD1Ifxp4V
# pX6+n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHiLQwb7iDVySAd
# YyktzuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhmV1efVFiODCu3
# T6cw2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHEtWoYOAMQjdjU
# N6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6MUSaM0C/CNda
# SaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mXaXpI8OCiEhtm
# mnTK3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZxd9LBADMfRyV
# w4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfhvbfmQ6QYuKZ3
# AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvlEFDrMcXKchYi
# Cd98THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn15GkvmB0t9dmp
# sh3lGwIDAQABo4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU7Nfj
# gtJxXWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNt
# yA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYY
# aHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2Fj
# ZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MEUG
# A1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRVHSAAMA0GCSqGSIb3
# DQEBDAUAA4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyhhyzshV6pGrsi+Ica
# aVQi7aSId229GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO0Cre+i1Wz/n096ww
# epqLsl7Uz9FDRJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo8L8vC6bp8jQ87PcD
# x4eo0kxAGTVGamlUsLihVo7spNU96LHc/RzY9HdaXFSMb++hUD38dglohJ9vytsg
# jTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5xaiNrIv8SuFQtJ37Y
# OtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o4rmUMYIDdjCCA3ICAQEwdzBjMQswCQYD
# VQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lD
# ZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBAhAF
# RK/zlJ0IOaa/2z9f5WEWMA0GCWCGSAFlAwQCAQUAoIHRMBoGCSqGSIb3DQEJAzEN
# BgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjMxMTA2MTcxMTU0WjArBgsq
# hkiG9w0BCRACDDEcMBowGDAWBBRm8CsywsLJD4JdzqqKycZPGZzPQDAvBgkqhkiG
# 9w0BCQQxIgQghM2qv+oC2YmOb/9Ehoc9PJM3er+MNFHkzAQrRUVO/kEwNwYLKoZI
# hvcNAQkQAi8xKDAmMCQwIgQg0vbkbe10IszR1EBXaEE2b4KK2lWarjMWr00amtQM
# eCgwDQYJKoZIhvcNAQEBBQAEggIAkDJbC6u/Dn8cEtOSXX7RnZL6wZTltmqwDxhY
# FY75akYqhAa3Quxjpwwvte8i44XRFcR8Vad9Wz1vNgPrMS3+y9QVpdwvPmk+ui5W
# 0NEnp9PrpFV2JnpKVo9jemF2RYdogGxM3a8CdSQjoOapnaBE4fbIVllz6PQQwxbx
# rv1lcKXLCUdVH/iuY9e+rN0+ChWqPsARhDsxjpOiHb0OWfaAVOhSBVt2ZeuPAdaZ
# kJaMleBRXFnT9XlS0akvSDNKFYQOU3zVOIFRTh1cnoRciZ+/cy6k1j98LT6qUaTv
# FMlQIB2twA9Z+sZJ72vzdv0EGxIam52mwdJOvkCIEJfR+cdxgOu0VdaU5olSkR3e
# zRLgfimirXzbmSExx2wCtNmgJUfijTOFkzRZGguE1SkQaEdhhmCwCRcBcmOFJC31
# edKg14H8lJe0Bya56BcZAkOCC4090/rfpeDN246DmDm1JOsLoX78DJwRIaZY7OI/
# yUzqMA4dSjXAO/mP9p7ACrVcx0V4vNG7JygGvexceTR/7OIVZwp8e1PRUHbUwxB7
# z7E/7mWdHl+0I7xEERVlJtY9ey3YvufJHQDT3MomoRJ8HvDe7WfEU++XO4lpugMK
# YlGJ/Tdq4gFr/EK9N3LthUm7qrRdtUR2487jdjhAOq9x5jLXzfJm2BgiGocyZhnp
# /d/CySA=
# SIG # End signature block
