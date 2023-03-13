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
    $Script:TestGroup = $Groups | where { $_.groupName -eq $TestGroupName }
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
    # Sanitise activation ID from previous response
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
        $AddBucketHostnames[0].cnameFrom | Should -Be $AdditionalHostname
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
        $RemoveBucketHostnames.count | Should -Not -BeNullOrEmpty
    }

    ### Remove-BucketActivation
    $Script:BucketActivationCancellation = Remove-BucketActivation -PropertyID 123456 -ActivationID $BucketActivations[0].hostnameActivationId -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Remove-BucketActivation returns the correct data' {
        $BucketActivationCancellation.hostnameActivationId | Should -Be $BucketActivations[0].hostnameActivationId
    }
}

# SIG # Begin signature block
# MIIoaAYJKoZIhvcNAQcCoIIoWTCCKFUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUuvnp3woXu79Pd5cxbIX1BBUD
# lBWggiGYMIIFjTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0B
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
# MCMGCSqGSIb3DQEJBDEWBBSNACJvWjmO2CclZqvHqXDlgGOJEjANBgkqhkiG9w0B
# AQEFAASCAgA6ElGeuZlYHaDHkXENiXP2sDhMqc1TIZvBa84wCBkNMjX1jZ3O7sVT
# 7oMKExcO9V2WjxYpJlfyc2UrSztj/I77eu8YSHuW36OYfKaPH2S7kunW9wSgc9S8
# BJvymvcfCvb2OXbiMu/JySs5upQNBAcDwN/SkRlD0nz6FUHyt5YPMtu0stkUZEhS
# j8qFOVDfEEJFPyZsqZD2UvNMXU6SAMxHmCu3PWbYATPQeD2BxPotrw77XxUcA3QY
# a+Ve2Mms9uPJaylDp7RQWkS5qdP/Yaz+RfiMXfdKAE7ad4Lle55EhC41S5vuYMHf
# pXcHh54cfmiflfn31yar7wy62qKp2mXyoAnhFq8WeadlF52P/IFRqNcjFTK/SdTe
# vt7Y1gfbHFN8nRKlSQVYawzsvjiZR13W4LDRIqO9ATttw3aPsC6cYXx8xX2wIIS2
# N8TAqfuXLeZlIrcUoDjLm+0qL2bW7axib+peIeu8PzlUgT6O9jqS/CjeuQYFH4nR
# 9mR5MkQ5/hWe8fkigSh9LaA+i1qQpdqeYcZfVVJJJmw9xFvwo9i64gksC4zTThSA
# m1hz7QwKgGbewRmO6/Isz2i51PXf6lyAwySlpeQsxqNzrCVry1k/N9n+seoxikJL
# kYoU9ndcbrcGdKPzzLohbB15bbK30xHZNB+1z9+U/Z2XR4Yc48vnFqGCAyAwggMc
# BgkqhkiG9w0BCQYxggMNMIIDCQIBATB3MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
# Ew5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBS
# U0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAxNaXJLlPo8Kko9KQeAPVow
# DQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqG
# SIb3DQEJBTEPFw0yMzAyMjcxNjMwMDNaMC8GCSqGSIb3DQEJBDEiBCBs3TItfUuj
# UDOpZWKgesriqTArPYiZR0cGiYHU/kRL0DANBgkqhkiG9w0BAQEFAASCAgC22TJn
# U3Szatw0A+/022S6uyX4jlqqdrL42Cuma4rJpy10tS0kNBTX0V2t7rqngHI2vqaI
# 2H23JID+bqjcaBq2vqUUro2aXhKCS7RwkJNikRir9p+ekLcJbwZoT+lGTiOTBnP+
# B1AYB8iJZeJXA0KzJNAVLYVDr7H7OTnmD8Qc9uzRJktJEavI8FW2yaVgS9T6wmKJ
# 0nWfeIhmJUdx+oVNzoc3tZPiHkeoJINuUYwNnh3DA//r4GTIRCRPkzqmU2Rpyk8w
# FmefJgOdvXibbb1GKI85nEZZHkJipIuxW9LLte7BtT2mz0DirZKNND8yVBD7AE9b
# JLqa3lrnBh0FlkZiqrQQ6AUjXkbFT5pOhpnhqBr3hWnvWEcTlNMnjBHAKlzUh0q0
# nPvKlluh1wHMYhGaDt4RxSF9kBja9ZbpHDqRmeyZ4xWWsjOXiWmJYo+D81A/xNRh
# 9gT3LHWacCmsByRV+e9Ggqh3TkyEI0mUos6oXgxjQ6aL7835VV0ULFJC9XFsBev6
# WquRUUg2eVQ+2Oo7p+5P1eyNC3urkhJkvOKDm6Qk+4lF384/OmJTl65ShSy3r+7O
# 7KWpRxIwtz8kxSgnm+yMUBpj5dLS6TqCNGNoQmkbUwe6YOCnPRasxK9ZAkjjRZ+/
# p1MQTqC5QLbipH4i4cLSQQ6J2z0QAglPkt4jeA==
# SIG # End signature block
