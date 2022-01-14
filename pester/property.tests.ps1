Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestContract = '1-1NC95D'
$Script:TestGroupName = 'AkamaiPowershell'
$Script:TestPropertyName = 'akamaipowershell-testing'
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
        $Contracts.count | Should -BeGreaterThan 0
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
        $TopLevelGroups.count | Should -BeGreaterThan 0
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
    it 'Get-CustomBehaviors should not be null' {
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
    it 'Get-PropertyRuleTree returns rules object' {
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
    it 'List-RuleFormats returns results' {
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

    AfterAll {
        ### Cleanup files
        Remove-Item rules.json -Force
        Remove-Item templates.json -Force
        Remove-Item templates -Recurse -Force
    }
    
}

Describe 'Unsafe PAPI Tests' {
    ### New-Property
    $Script:NewProperty = New-Property -PropertyName $TestPropertyName -ProductID SPM -GroupID $TestGroup.groupId -ContractId $TestContract -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'New-Property creates a property' {
        $NewProperty.propertyLink | Should -Not -BeNullOrEmpty
    }

    ### Remove-Property
    $Script:RemoveProperty = Remove-Property -PropertyID 000000 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Remove-Property removes a property' {
        $RemoveProperty.message | Should -Be "Deletion Successful."
    }

    ### New-EdgeHostname
    $Script:NewEdgeHostname = New-EdgeHostname -DomainPrefix test -DomainSuffix edgesuite.net -IPVersionBehavior IPV4 -ProductId SPM -SecureNetwork STANDARD_TLS -GroupID $TestGroup.groupId -ContractId $TestContract -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'New-Property creates a property' {
        $NewEdgeHostname.edgeHostnameLink | Should -Not -BeNullOrEmpty
    }

    ### New-CPCode
    $Script:NewCPCode = New-CPCode -CPCodeName testCP -ProductId SPM -GroupID $TestGroup.groupId -ContractId $TestContract -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'New-Property creates a property' {
        $NewCPCode.cpcodeLink | Should -Not -BeNullOrEmpty
    }
}