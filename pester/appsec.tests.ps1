Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestConfigName = "akamaipowershell"
$Script:TestConfigDescription = "Powershell pester testing. Will be deleted shortly."
$Script:TestContract = '1-1NC95D'
$Script:TestGroupID = 209759
$Script:TestHostnames = 'akamaipowershell-testing.edgesuite.net'
$Script:TestAPIEndpointID = 817948
$Script:TestCustomRule = '{"conditions":[{"type":"pathMatch","positiveMatch":true,"value":["/test"],"valueCase":false,"valueIgnoreSegment":false,"valueNormalize":false,"valueWildcard":true}],"name":"cr1","operation":"AND","ruleActivated":false,"structured":true,"tag":["tag1"],"version":1}'
$Script:TestNotes = "Akamai PowerShell Test"
$Script:TestPolicyName = 'Example'
$Script:TestPolicyPrefix = 'EX01'
$Script:TestPolicyMode = 'ASE_MANUAL'
$Script:TestMatchTargetBody = '{"type":"api","apis":[{"id":APIID}],"securityPolicy":{"policyId":"id1"}}'.replace("APIID", $TestAPIEndpointID)
$Script:TestMatchTarget = ConvertFrom-Json $TestMatchTargetBody
$Script:TestNetworkListID = '365_AKAMAITOREXITNODES'
$Script:TestCustomDenyName = 'SampleCustomDeny'
$Script:TestCustomDenyBody = '{"name":"PlaceHolder","description": "Old Description","parameters":[{"displayName":"Hostname","name":"custom_deny_hostname","value":"deny.akamaipowershell-testing.edgesuite.net"},{"displayName":"Path","name":"custom_deny_path","value":"/"},{"displayName":"IncludeAkamaiReferenceID","name":"include_reference_id","value":"true"},{"displayName":"IncludeTrueClientIP","name":"include_true_ip","value":"false"},{"displayName":"Preventbrowsercaching","name":"prevent_browser_cache","value":"true"},{"displayName":"Responsecontenttype","name":"response_content_type","value":"application/json"},{"displayName":"Responsestatuscode","name":"response_status_code","value":"403"}]}'.replace('PlaceHolder', $TestCustomDenyName)
$Script:TestRatePolicy1Name = 'Rate Policy 1'
$Script:TestRatePolicy2Name = 'Rate Policy 2'
$Script:TestRatePolicyBody = '{"averageThreshold":10,"burstThreshold":50,"clientIdentifier":"ip","matchType":"path","name":"PlaceHolder","path":{"positiveMatch":true,"values":["/*"]},"pathMatchType":"Custom","pathUriPositiveMatch":true,"requestType":"ClientRequest","sameActionOnIpv6":false,"type":"WAF","useXForwardForHeaders":false}'.replace('PlaceHolder', $TestRatePolicy1Name)
$Script:TestRatePolicy = ConvertFrom-Json $TestRatePolicyBody
$TestRatePolicy.name = $TestRatePolicy2Name
$Script:TestSiemSettingsBody = '{"enableSiem":true,"enableForAllPolicies":true, "siemDefinitionId": 1}'
$Script:TestSiemSettings = ConvertFrom-Json $TestSiemSettingsBody
$Script:TestReputationProfile1Name = "AkamaiPowerShell Reputation Profile 1"
$Script:TestReputationProfile2Name = "AkamaiPowerShell Reputation Profile 2"
$Script:TestReputationProfileBody = '{"context":"DOSATCK","contextReadable":"DoSAttackers","enabled":true,"name":"PlaceHolder","sharedIpHandling":"BOTH","threshold":7}'.replace('PlaceHolder', $TestReputationProfile1Name)
$Script:TestReputationProfile = ConvertFrom-Json $TestReputationProfileBody
$TestReputationProfile.name = $TestReputationProfile2Name
$Script:TestPragmaSettingsBody = '{"action":"REMOVE","conditionOperator":"AND"}'
$Script:TestPragmaSettings = ConvertFrom-Json $TestPragmaSettingsBody
$Script:TestExceptionBody = '{"exception":{"specificHeaderCookieParamXmlOrJsonNames":[{"names":["ExceptMe"],"selector":"REQUEST_HEADERS","wildcard":true}]}}'
$Script:TestException = ConvertFrom-Json $TestExceptionBody
$Script:TestRuleID = 950002
$Script:TestAttackGroupID = 'CMD'

Describe 'Safe AppSec Tests' {
    BeforeDiscovery {
    }

    #************************************************#
    #                 Configuration                  #
    #************************************************#

    ### New-AppSecConfiguration
    $Script:NewConfig = New-AppSecConfiguration -Name $TestConfigName -Description $TestConfigDescription -GroupID $TestGroupID -ContractId $TestContract -Hostnames $TestHostnames -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecConfiguration creates successfully' {
        $NewConfig.name | Should -Be $TestConfigName
    }

    ### List-AppSecConfigurations
    $Script:Configs = List-AppSecConfigurations -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecConfigurations gets a list of configs' {
        $Configs | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecConfiguration by Name
    $Script:Config = Get-AppSecConfiguration -ConfigName $TestConfigName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecConfiguration by Name finds the config' {
        $Config | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecConfiguration by ID
    $Script:Config = Get-AppSecConfiguration -ConfigID $NewConfig.configId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecConfiguration by ID finds the config' {
        $Config | Should -Not -BeNullOrEmpty
    }

    ### Rename-AppSecConfiguration
    $Script:RenameResult = Rename-AppSecConfiguration -ConfigID $NewConfig.configId -NewName $TestConfigName -Description $TestConfigDescription -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Rename-AppSecConfiguration successfully renames' {
        $RenameResult.Name | Should -Be $TestConfigName
    }

    #************************************************#
    #                  Custom Rules                  #
    #************************************************#

    ### New-AppSecCustomRule
    $Script:NewCustomRule = New-AppSecCustomRule -ConfigID $NewConfig.configId -Body $TestCustomRule -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecCustomRule creates successfully' {
        $NewCustomRule.id | Should -Not -BeNullOrEmpty
    }

    ### List-AppSecCustomRules
    $Script:CustomRules = List-AppSecCustomRules -ConfigID $NewConfig.configId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecCustomRules returns something' {
        $CustomRules | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecCustomRule
    $Script:CustomRule = Get-AppSecCustomRule -ConfigID $NewConfig.configId -RuleID $NewCustomRule.id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecCustomRule returns newly created rule' {
        $CustomRule.id | Should -Be $NewCustomRule.id
    }

    ### Set-AppSecCustomRule by pipeline
    it 'Set-AppSecCustomRule completes successfully' {
        { $Script:SetCustomRule = $NewCustomRule | Set-AppSecCustomRule -ConfigID $NewConfig.configId -RuleID $NewCustomRule.id -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    ### Set-AppSecCustomRule by body
    it 'Set-AppSecCustomRule completes successfully' {
        { $Script:SetCustomRule = Set-AppSecCustomRule -ConfigID $NewConfig.configId -RuleID $NewCustomRule.id -Body $TestCustomRule -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    #************************************************#
    #               Failover Hostnames               #
    #************************************************#

    ### List-AppSecFailoverHostnames
    it 'List-AppSecFailoverHostnames does not throw' {
        { $Script:FailoverHostnames = List-AppSecFailoverHostnames -ConfigID $NewConfig.configId -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    #************************************************#
    #               Version Notes                    #
    #************************************************#

    ### Set-AppSecVersionNotes
    $Script:SetNotes = Set-AppSecVersionNotes -ConfigID $NewConfig.configId -VersionNumber 1 -Notes $TestNotes -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecVersionNotes sets notes correctly' {
        $SetNotes | Should -Be $TestNotes
    }

    ### Get-AppSecVersionNotes
    $Script:GetNotes = Get-AppSecVersionNotes -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecVersionNotes gets notes correctly' {
        $GetNotes | Should -Be $TestNotes
    }

    #************************************************#
    #                Hostname Coverage               #
    #************************************************#

    ### Get-AppSecHostnameCoverage
    $Script:Coverage = Get-AppSecHostnameCoverage -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecHostnameCoverage gets a list' {
        $Coverage.count | Should -Not -BeNullOrEmpty
    }

    #************************************************#
    #                    Hostnames                   #
    #************************************************#

    ### List-AppSecSelectableHostnames
    $Script:SelectableHostnames = List-AppSecSelectableHostnames -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecSelectableHostnames gets a list' {
        $SelectableHostnames[0].hostname | Should -Not -BeNullOrEmpty
    }

    ### List-AppSecSelectedHostnames
    $Script:SelectedHostnames = List-AppSecSelectedHostnames -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecSelectedHostnames gets a list' {
        $SelectedHostnames | Should -Contain $TestHostnames
    }

    ### List-AppSecAvailableHostnames
    $Script:SelectableHostnames = List-AppSecAvailableHostnames -ContractID $TestContract -GroupID $TestGroupID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecAvailableHostnames gets a list' {
        $SelectableHostnames[0].hostname | Should -Not -BeNullOrEmpty
    }

    #************************************************#
    #                    Policies                    #
    #************************************************#

    ### New-AppSecPolicy
    $Script:NewPolicy = New-AppSecPolicy -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyName $TestPolicyName -PolicyPrefix $TestPolicyPrefix -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecPolicy creates correctly' {
        $NewPolicy.policyName | Should -Be $TestPolicyName
    }

    ### List-AppSecPolicies
    $Script:Policies = List-AppSecPolicies -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecPolicies returns a list' {
        $Policies[0].policyId | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecPolicy by ID and version
    $Script:PolicyByID = Get-AppSecPolicy -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId  -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicy by ID returns the correct policy' {
        $PolicyByID.policyId | Should -Be $NewPolicy.policyId
    }

    ### Get-AppSecPolicy by name and latest
    $Script:PolicyByName = Get-AppSecPolicy -ConfigName $TestConfigName -VersionNumber latest -PolicyID $NewPolicy.policyId  -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicy by name returns the correct policy' {
        $PolicyByName.policyId | Should -Be $NewPolicy.policyId
    }

    ### Set-AppSecPolicy to new name
    $Script:RenamePolicy = Set-AppSecPolicy -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -NewName "Temp" -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicy updates correctly' {
        $RenamePolicy.policyName | Should -Be "Temp"
    }

    ### Set-AppSecPolicy back to old name in case we need it later
    $Script:SetPolicy = Set-AppSecPolicy -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -NewName $TestPolicyName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicy updates correctly' {
        $SetPolicy.policyName | Should -Be $TestPolicyName
    }

    #************************************************#
    #                  Match Targets                 #
    #************************************************#

    $TestMatchTarget.securityPolicy.policyId = $NewPolicy.policyId
    ### New-AppSecMatchTarget
    $Script:NewMatchTarget = New-AppSecMatchTarget -ConfigID $NewConfig.configId -VersionNumber 1 -MatchTarget $TestMatchTarget -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecMatchTarget creates correctly' {
        $NewMatchTarget.configId | Should -Be $NewConfig.configId
    }

    ### List-AppSecMatchTargets
    $Script:MatchTargets = List-AppSecMatchTargets -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecMatchTargets returns a list' {
        $MatchTargets.apiTargets | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecMatchTarget
    $Script:MatchTarget = Get-AppSecMatchTarget -ConfigID $NewConfig.configId -VersionNumber 1 -TargetID $NewMatchTarget.targetId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecMatchTarget returns the correct target' {
        $MatchTarget | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecMatchTarget by pipeline
    $Script:SetMatchTargetByPipeline = ( $NewMatchTarget | Set-AppSecMatchTarget -ConfigID $NewConfig.configId -VersionNumber 1 -TargetID $NewMatchTarget.targetId -EdgeRCFile $EdgeRCFile -Section $Section )
    it 'Set-AppSecMatchTarget by pipeline updates successfully' {
        $SetMatchTargetByPipeline.targetId | Should -Be $NewMatchTarget.targetId
    }

    ### Set-AppSecMatchTarget by param
    $Script:SetMatchTargetByParam = Set-AppSecMatchTarget -ConfigID $NewConfig.configId -VersionNumber 1 -TargetID $NewMatchTarget.targetId -MatchTarget $NewMatchTarget -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecMatchTarget by param updates successfully' {
        $SetMatchTargetByParam.targetId | Should -Be $NewMatchTarget.targetId
    }

    ### Set-AppSecMatchTarget by body
    $Script:SetMatchTargetByBody = Set-AppSecMatchTarget -ConfigID $NewConfig.configId -VersionNumber 1 -TargetID $NewMatchTarget.targetId -Body (ConvertTo-Json -Depth 10 $NewMatchTarget) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecMatchTarget by body updates successfully' {
        $SetMatchTargetByBody.targetId | Should -Be $NewMatchTarget.targetId
    }

    #************************************************#
    #                IP/Geo Firewall                 #
    #************************************************#

    # ### Set-AppSecBypassNetworkLists
    # $Script:SetBypassNL = Set-AppSecBypassNetworkLists -ConfigID $NewConfig.configId -VersionNumber 1 -NetworkLists $TestNetworkListID -EdgeRCFile $EdgeRCFile -Section $Section
    # it 'Set-AppSecBypassNetworkLists updates successfully' {
    #     $SetBypassNL.ipControls.allowedIPNetworkLists.networkList | Should -Contain $TestNetworkListID
    # }

    # ### Get-AppSecBypassNetworkLists
    # $Script:BypassNL = Get-AppSecBypassNetworkLists -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    # it 'Get-AppSecBypassNetworkLists returns the correct data' {
    #     $BypassNL.networkLists.id | Should -Contain $TestNetworkListID
    # }

    ### Get-AppSecPolicyIPGeoFirewall
    $Script:IPGeo = Get-AppSecPolicyIPGeoFirewall -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyIPGeoFirewall returns the correct data' {
        $IPGeo.block | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyIPGeoFirewall by pipeline
    $Script:SetIPGeoByPipeline = ($IPGeo | Set-AppSecPolicyIPGeoFirewall -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPolicyIPGeoFirewall by pipeline returns the correct data' {
        $SetIPGeoByPipeline.block | Should -Be $IPGeo.block
    }

    ### Set-AppSecPolicyIPGeoFirewall by param
    $Script:SetIPGeoByParam = Set-AppSecPolicyIPGeoFirewall -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -IPGeoFirewallSettings $IPGeo -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyIPGeoFirewall by param returns the correct data' {
        $SetIPGeoByParam.block | Should -Be $IPGeo.block
    }

    ### Set-AppSecPolicyIPGeoFirewall by body
    $Script:SetIPGeoByBody = Set-AppSecPolicyIPGeoFirewall -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -Body (ConvertTo-Json -Depth 10 $IPGeo) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyIPGeoFirewall by body returns the correct data' {
        $SetIPGeoByBody.block | Should -Be $IPGeo.block
    }

    #************************************************#
    #                  Rate Policies                 #
    #************************************************#

    ### New-AppSecRatePolicy by body
    $Script:NewRatePolicyByBody = New-AppSecRatePolicy -ConfigID $NewConfig.configId -VersionNumber 1 -Body $TestRatePolicyBody -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecRatePolicy by body creates correctly' {
        $NewRatePolicyByBody.name | Should -Be $TestRatePolicy1Name
    }

    ### New-AppSecRatePolicy by pipeline
    $Script:NewRatePolicyByPipeline = $TestRatePolicy | New-AppSecRatePolicy -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecRatePolicy by pipeline creates correctly' {
        $NewRatePolicyByPipeline.name | Should -Be $TestRatePolicy2Name
    }

    ### List-AppSecRatePolicies
    $Script:RatePolicies = List-AppSecRatePolicies -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecRatePolicies returns a list' {
        $RatePolicies.count | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecRatePolicy
    $Script:RatePolicy = Get-AppSecRatePolicy -ConfigID $NewConfig.configId -VersionNumber 1 -RatePolicyID $NewRatePolicyByBody.id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecRatePolicy returns the correct policy' {
        $RatePolicy.name | Should -Be $TestRatePolicy1Name
    }

    ### Set-AppSecRatePolicy by pipeline
    $Script:SetRatePolicyByPipeline = ($NewRatePolicyByBody | Set-AppSecRatePolicy -ConfigID $NewConfig.configId -VersionNumber 1 -RatePolicyID $NewRatePolicyByBody.id -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecRatePolicy by pipeline returns the correct policy' {
        $SetRatePolicyByPipeline.name | Should -Be $TestRatePolicy1Name
    }

    ### Set-AppSecRatePolicy by param
    $Script:SetRatePolicyByParam = Set-AppSecRatePolicy -ConfigID $NewConfig.configId -VersionNumber 1 -RatePolicyID $NewRatePolicyByBody.id -RatePolicy $NewRatePolicyByBody -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecRatePolicy by param returns the correct policy' {
        $SetRatePolicyByParam.name | Should -Be $TestRatePolicy1Name
    }

    ### Set-AppSecRatePolicy by body
    $Script:SetRatePolicyByBody = Set-AppSecRatePolicy -ConfigID $NewConfig.configId -VersionNumber 1 -RatePolicyID $NewRatePolicyByBody.id -Body (ConvertTo-Json -Depth 10 $NewRatePolicyByBody) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecRatePolicy by body returns the correct policy' {
        $SetRatePolicyByBody.name | Should -Be $TestRatePolicy1Name
    }

    #************************************************#
    #                   Custom Deny                  #
    #************************************************#

    ### New-AppSecCustomDenyAction
    $Script:NewCustomDenyAction = New-AppSecCustomDenyAction -ConfigID $NewConfig.configId -VersionNumber 1 -Body $TestCustomDenyBody -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecCustomDenyAction creates correctly' {
        $NewCustomDenyAction.name | Should -Be $TestCustomDenyName
    }

    ### List-AppSecCustomDenyActions
    $Script:CustomDenyActions = List-AppSecCustomDenyActions -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecCustomDenyActions lists correctly' {
        $CustomDenyActions[0].name | Should -Be $TestCustomDenyName
    }

    ### Get-AppSecCustomDenyAction
    $Script:CustomDenyAction = Get-AppSecCustomDenyAction -ConfigID $NewConfig.configId -VersionNumber 1 -CustomDenyID $NewCustomDenyAction.id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecCustomDenyAction returns the correct action' {
        $CustomDenyAction.name | Should -Be $TestCustomDenyName
    }

    ### Set-AppSecCustomDenyAction
    $NewCustomDenyAction.description = "updated"
    $Script:SetCustomDenyAction = ($NewCustomDenyAction | Set-AppSecCustomDenyAction -ConfigID $NewConfig.configId -VersionNumber 1 -CustomDenyID $NewCustomDenyAction.id -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecCustomDenyAction updates correctly' {
        $SetCustomDenyAction.description | Should -Be "updated"
    }

    ### Set-AppSecCustomDenyAction
    $NewCustomDenyAction.description = "updated"
    $Script:SetCustomDenyAction = ($NewCustomDenyAction | Set-AppSecCustomDenyAction -ConfigID $NewConfig.configId -VersionNumber 1 -CustomDenyID $NewCustomDenyAction.id -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecCustomDenyAction updates correctly' {
        $SetCustomDenyAction.description | Should -Be "updated"
    }

    #************************************************#
    #                       SIEM                     #
    #************************************************#

    
    ### Set-AppSecSiemSettings by body
    $Script:SetSIEMSettings = Set-AppSecSiemSettings -ConfigID $NewConfig.configId -VersionNumber 1 -Body $TestSiemSettingsBody -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecSiemSettings by body updates correctly' {
        $SetSIEMSettings.enableForAllPolicies | Should -Be $true
    }

    ### Set-AppSecSiemSettings by pipeline
    $Script:SetSIEMSettings = ($TestSiemSettings | Set-AppSecSiemSettings -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecSiemSettings by pipeline updates correctly' {
        $SetSIEMSettings.enableForAllPolicies | Should -Be $true
    }

    ### Get-AppSecSiemSettings by pipeline
    $Script:SIEMSettings = Get-AppSecSiemSettings -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecSiemSettings gets the right settings' {
        $SIEMSettings.enableForAllPolicies | Should -Be $true
    }

    #************************************************#
    #               Reputation Profiles              #
    #************************************************#

    ### New-AppSecReputationProfile by body
    $Script:NewReputationProfileByBody = New-AppSecReputationProfile -ConfigID $NewConfig.configId -VersionNumber 1 -Body $TestReputationProfileBody -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecReputationProfile by body creates correctly' {
        $NewReputationProfileByBody.name | Should -Be $TestReputationProfile1Name
    }

    ### New-AppSecReputationProfile by pipeline
    $Script:NewReputationProfileByPipeline = ($TestReputationProfile | New-AppSecReputationProfile -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'New-AppSecReputationProfile by pipeline creates correctly' {
        $NewReputationProfileByPipeline.name | Should -Be $TestReputationProfile2Name
    }

    ### List-AppSecReputationProfiles
    $Script:ReputationProfiles = List-AppSecReputationProfiles -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecReputationProfiles returns a list' {
        $ReputationProfiles.count | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecReputationProfile
    $Script:ReputationProfile = Get-AppSecReputationProfile -ConfigID $NewConfig.configId -VersionNumber 1 -ReputationProfileID $NewReputationProfileByBody.id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecReputationProfile returns the correct profile' {
        $ReputationProfile.id | Should -Be $NewReputationProfileByBody.id
    }

    ### Set-AppSecReputationProfile by pipeline
    $Script:SetReputationProfileByPipeline = ($NewReputationProfileByBody | Set-AppSecReputationProfile -ConfigID $NewConfig.configId -VersionNumber 1 -ReputationProfileID $NewReputationProfileByBody.id -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecReputationProfile by pipeline updates the correct profile' {
        $SetReputationProfileByPipeline.id | Should -Be $NewReputationProfileByBody.id
    }

    ### Set-AppSecReputationProfile by param
    $Script:SetReputationProfileByParam = Set-AppSecReputationProfile -ConfigID $NewConfig.configId -VersionNumber 1 -ReputationProfileID $NewReputationProfileByBody.id -ReputationProfile $NewReputationProfileByBody -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecReputationProfile by param updates the correct profile' {
        $SetReputationProfileByParam.id | Should -Be $NewReputationProfileByBody.id
    }

    ### Set-AppSecReputationProfile by body
    $Script:SetReputationProfileByBody = Set-AppSecReputationProfile -ConfigID $NewConfig.configId -VersionNumber 1 -ReputationProfileID $NewReputationProfileByBody.id -Body (ConvertTo-Json -Depth 10 $NewReputationProfileByBody) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecReputationProfile by body updates the correct profile' {
        $SetReputationProfileByBody.id | Should -Be $NewReputationProfileByBody.id
    }

    #************************************************#
    #                    Advanced                    #
    #************************************************#

    ### Get-AppSecEvasivePathMatch
    $Script:EvasivePathMatch = Get-AppSecEvasivePathMatch -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecEvasivePathMatch returns the correct data' {
        $EvasivePathMatch.enablePathMatch | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecEvasivePathMatch
    $Script:SetEvasivePathMatch = Set-AppSecEvasivePathMatch -ConfigID $NewConfig.configId -VersionNumber 1 -EnablePathMatch $true -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecEvasivePathMatch updates correctly' {
        $SetEvasivePathMatch.enablePathMatch | Should -Be $true
    }

    ### Get-AppSecLogging
    $Script:Logging = Get-AppSecLogging -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecLogging returns the correct data' {
        $Logging.allowSampling | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecLogging by pipeline
    $Script:SetLoggingByPipeline = ($Logging | Set-AppSecLogging -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecLogging updates correctly' {
        $SetLoggingByPipeline.allowSampling | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecLogging by body
    $Script:SetLoggingByBody = Set-AppSecLogging -ConfigID $NewConfig.configId -VersionNumber 1 -Body (ConvertTo-Json -Depth 10 $Logging) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecLogging updates correctly' {
        $SetLoggingByBody.allowSampling | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPragmaSettings by body
    $Script:SetPragmaSettingsByBody = Set-AppSecPragmaSettings -ConfigID $NewConfig.configId -VersionNumber 1 -Body $TestPragmaSettingsBody -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPragmaSettings by body returns the correct data' {
        $SetPragmaSettingsByBody.action | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPragmaSettings by pipeline
    $Script:SetPragmaSettingsByPipeline = ($TestPragmaSetting | Set-AppSecPragmaSettings -ConfigID $NewConfig.configId -VersionNumber 1 -Body $TestPragmaSettingsBody -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPragmaSettings by pipeline returns the correct data' {
        $SetPragmaSettingsByPipeline.action | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecPragmaSettings
    $Script:PragmaSettings = Get-AppSecPragmaSettings -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPragmaSettings returns the correct data' {
        $PragmaSettings.action | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecPrefetch
    $Script:Prefetch = Get-AppSecPrefetch -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPrefetch returns the correct data' {
        $Prefetch.enableAppLayer | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPrefetch by pipeline
    $Script:SetPrefetchByPipeline = ($Prefetch | Set-AppSecPrefetch -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPrefetch by pipeline updates correctly' {
        $SetPrefetchByPipeline.enableAppLayer | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPrefetch by body
    $Script:SetPrefetchByBody = Set-AppSecPrefetch -ConfigID $NewConfig.configId -VersionNumber 1 -Body (ConvertTo-Json -Depth 10 $Prefetch) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPrefetch by body updates correctly' {
        $SetPrefetchByBody.enableAppLayer | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecRequestSizeLimit
    $Script:RequestSizeLimit = Get-AppSecRequestSizeLimit -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecRequestSizeLimit returns the correct data' {
        $RequestSizeLimit.requestBodyInspectionLimitInKB | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecRequestSizeLimit
    $Script:SetRequestSizeLimit = Set-AppSecRequestSizeLimit -ConfigID $NewConfig.configId -VersionNumber 1 -RequestSizeLimit 32 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecRequestSizeLimit updates correctly' {
        $SetRequestSizeLimit.requestBodyInspectionLimitInKB | Should -Be 32
    }

    #************************************************#
    #                   Protections                  #
    #************************************************#

    ### Get-AppSecPolicyProtections
    $Script:Protections = Get-AppSecPolicyProtections -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyProtections returns the correct data' {
        $Protections.applyApiConstraints | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyProtections by pipeline
    $Script:SetProtectionsByPipeline = ($Protections | Set-AppSecPolicyProtections -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPolicyProtections by pipeline updates correctly' {
        $SetProtectionsByPipeline.applyApiConstraints | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyProtections by body
    $Script:SetProtectionsByBody = Set-AppSecPolicyProtections -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -Body (ConvertTo-Json -Depth 10 $Protections) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyProtections by body updates correctly' {
        $SetProtectionsByBody.applyApiConstraints | Should -Not -BeNullOrEmpty
    }

    #************************************************#
    #                   Penalty Box                  #
    #************************************************#

    ### Get-AppSecPolicyPenaltyBox
    $Script:PenaltyBox = Get-AppSecPolicyPenaltyBox -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyPenaltyBox returns the correct data' {
        $PenaltyBox.penaltyBoxProtection | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyPenaltyBox by pipeline
    $Script:SetPenaltyBoxByPipeline = ($PenaltyBox | Set-AppSecPolicyPenaltyBox -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPolicyPenaltyBox by pipeline updates correctly' {
        $SetPenaltyBoxByPipeline.penaltyBoxProtection | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyPenaltyBox by body
    $Script:SetPenaltyBoxByBody = Set-AppSecPolicyPenaltyBox -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -Body (ConvertTo-Json -Depth 10 $PenaltyBox) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyPenaltyBox by body updates correctly' {
        $SetPenaltyBoxByBody.penaltyBoxProtection | Should -Not -BeNullOrEmpty
    }

    #************************************************#
    #               Rate Policy Actions              #
    #************************************************#

    ### Set-AppSecPolicyRatePolicy
    $Script:SetRatePolicyAction = Set-AppSecPolicyRatePolicy -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -RatePolicyID $NewRatePolicyByBody.id -IPv4Action alert -IPv6Action alert -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyRatePolicy updates correctly' {
        $SetRatePolicyAction.ipv4Action | Should -Be 'alert'
    }

    ### List-AppSecPolicyRatePolicies
    $Script:RatePolicyActions = List-AppSecPolicyRatePolicies -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecPolicyRatePolicies returns the correct data' {
        $RatePolicyActions[0].id | Should -Not -BeNullOrEmpty
    }

    #************************************************#
    #             API Request Constraints            #
    #************************************************#

    ### List-AppSecPolicyAPIRequestConstraints
    $Script:APIRequestConstraints = List-AppSecPolicyAPIRequestConstraints -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecPolicyAPIRequestConstraints returns a list' {
        $APIRequestConstraints[0].action | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyAPIRequestConstraints without ID
    $Script:SetAPIRequestConstraints = Set-AppSecPolicyAPIRequestConstraints -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -Action "alert" -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyAPIRequestConstraints returns a list of actions' {
        $SetAPIRequestConstraints[0].action | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyAPIRequestConstraints with ID
    $Script:SetAPIRequestConstraint = Set-AppSecPolicyAPIRequestConstraints -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -ApiID $TestAPIEndpointID -Action "alert" -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyAPIRequestConstraints returns the correct action' {
        $SetAPIRequestConstraints[0].action | Should -Not -BeNullOrEmpty
    }

    #************************************************#
    #               Reputation Analysis              #
    #************************************************#

    ### Get-AppSecPolicyReputationAnalysis
    $Script:ReputationAnalysis = Get-AppSecPolicyReputationAnalysis -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyReputationAnalysis returns the correct data' {
        $ReputationAnalysis.forwardToHTTPHeader | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecPolicyReputationAnalysis by pipeline
    $Script:SetReputationAnalysisByPipeline = ($ReputationAnalysis | Set-AppSecPolicyReputationAnalysis -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPolicyReputationAnalysis by pipeline updates correctly' {
        $SetReputationAnalysisByPipeline.forwardToHTTPHeader | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecPolicyReputationAnalysis by body
    $Script:SetReputationAnalysisByBody = Set-AppSecPolicyReputationAnalysis -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -Body (ConvertTo-Json -Depth 10 $ReputationAnalysis) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyReputationAnalysis by body updates correctly' {
        $SetReputationAnalysisByBody.forwardToHTTPHeader | Should -Not -BeNullOrEmpty
    }

    #************************************************#
    #            Reputation Profile Actions          #
    #************************************************#

    ### List-AppSecPolicyReputationProfiles
    $Script:ReputationProfileActions = List-AppSecPolicyReputationProfiles -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecPolicyReputationProfiles returns a list' {
        $ReputationProfileActions.count | Should -BeGreaterThan 0
    }

    ### Get-AppSecPolicyReputationProfile
    $Script:ReputationProfileAction = Get-AppSecPolicyReputationProfile -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -ReputationProfileID $ReputationProfileActions[0].id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyReputationProfile returns a list' {
        $ReputationProfileAction.action | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyReputationProfile
    $Script:SetReputationProfileAction = Set-AppSecPolicyReputationProfile -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -ReputationProfileID $ReputationProfileActions[0].id -Action "deny" -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyReputationProfile updates correctly' {
        $SetReputationProfileAction.action | Should -Be "deny"
    }

    #************************************************#
    #                    Slow POST                   #
    #************************************************#

    ### Get-AppSecPolicySlowPostSettings
    $Script:SlowPost = Get-AppSecPolicySlowPostSettings -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicySlowPostSettings returns the correct data' {
        $ReputationProfileActions.action | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicySlowPostSettings by pipeline
    $Script:SetSlowPostByPipeline = ($SlowPost | Set-AppSecPolicySlowPostSettings -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPolicySlowPostSettings by pipeline completes successfully' {
        $SetSlowPostByPipeline.action | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicySlowPostSettings by body
    $Script:SetSlowPostByBody = Set-AppSecPolicySlowPostSettings -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -Body (ConvertTo-Json -depth 10 $SlowPost) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicySlowPostSettings by body completes successfully' {
        $SetSlowPostByBody.action | Should -Not -BeNullOrEmpty
    }

    #************************************************#
    #               Custom Rule Actions              #
    #************************************************#

    ### List-AppSecPolicyCustomRules
    $Script:CustomRuleActions = List-AppSecPolicyCustomRules -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecPolicyCustomRules returns a list' {
        $CustomRuleActions[0].action | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyCustomRule
    $Script:SetCustomRuleAction = Set-AppSecPolicyCustomRule -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -RuleID $NewCustomRule.id -Action 'deny' -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyCustomRule updates successfully' {
        $SetCustomRuleAction.action | Should -Be 'deny'
    }

    ### Set-AppSecPolicyCustomRule (undo so we can delete later)
    $Script:UnsetCustomRuleAction = Set-AppSecPolicyCustomRule -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -RuleID $NewCustomRule.id -Action 'none' -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyCustomRule updates successfully' {
        $UnsetCustomRuleAction.action | Should -Be 'none'
    }

    #************************************************#
    #             Policy Advanced Settings           #
    #************************************************#

    ### Get-AppSecPolicyEvasivePathMatch
    $Script:PolicyEvasivePathMatch = Get-AppSecPolicyEvasivePathMatch -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyEvasivePathMatch returns the correct data' {
        $PolicyEvasivePathMatch.enablePathMatch | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyEvasivePathMatch
    $Script:PolicyEvasivePathMatch = Set-AppSecPolicyEvasivePathMatch -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EnablePathMatch $true -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyEvasivePathMatch updates correctly' {
        $PolicyEvasivePathMatch.enablePathMatch | Should -Be $true
    }

    ### Get-AppSecPolicyLogging
    $Script:PolicyLogging = Get-AppSecPolicyLogging -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyLogging returns the correct data' {
        $PolicyLogging.override | Should -Not -BeNullOrEmpty
    }
    
    ### Set-AppSecPolicyLogging by pipeline
    $Script:SetPolicyLoggingByPipeline = ($PolicyLogging | Set-AppSecPolicyLogging -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPolicyLogging by pipeline updates correctly' {
        $SetPolicyLoggingByPipeline.override | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyLogging by body
    $Script:SetPolicyLoggingByBody = Set-AppSecPolicyLogging -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -Body (ConvertTo-Json -depth 10 $PolicyLogging) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyLogging by body updates correctly' {
        $SetPolicyLoggingByBody.override | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecPolicyPragmaSettings
    $Script:PolicyPragma = Get-AppSecPolicyPragmaSettings -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyPragmaSettings returns the correct data' {
        $PolicyPragma.override | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyPragmaSettings by pipeline
    $Script:SetPolicyPragmaByPipeline = ($TestPragmaSettings | Set-AppSecPolicyPragmaSettings -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPolicyPragmaSettings by pipeline returns the correct data' {
        $SetPolicyPragmaByPipeline.action | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyPragmaSettings by body
    $Script:SetPolicyPragmaByBody = Set-AppSecPolicyPragmaSettings -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -Body $TestPragmaSettingsBody -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyPragmaSettings by body returns the correct data' {
        $SetPolicyPragmaByBody.action | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecPolicyRequestSizeLimit
    $Script:PolicyRequestSizeLimit = Get-AppSecPolicyRequestSizeLimit -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyRequestSizeLimit returns the correct data' {
        $PolicyRequestSizeLimit.requestBodyInspectionLimitInKB | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyRequestSizeLimit
    $Script:SetPolicyRequestSizeLimit = Set-AppSecPolicyRequestSizeLimit -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -RequestSizeLimit 32 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyRequestSizeLimit updates correctly' {
        $SetPolicyRequestSizeLimit.requestBodyInspectionLimitInKB | Should -Be 32
    }

    #************************************************#
    #                      WAF                       #
    #************************************************#

    ### List-AppSecPolicyAttackGroups
    $Script:AttackGroups = List-AppSecPolicyAttackGroups -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecPolicyAttackGroups returns the correct data' {
        $AttackGroups.count | Should -BeGreaterThan 0
    }

    ### Get-AppSecPolicyAttackGroup
    $Script:AttackGroup = Get-AppSecPolicyAttackGroup -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -AttackGroupID $AttackGroups[0].group -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyAttackGroup returns the correct data' {
        $AttackGroup.action | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyAttackGroup
    $Script:SetAttackGroup = Set-AppSecPolicyAttackGroup -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -AttackGroupID $AttackGroups[0].group -Action "deny" -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyAttackGroup sets correctly' {
        $SetAttackGroup.action | Should -Be "deny"
    }

    ### Set-AppSecPolicyAttackGroupExceptions by pipeline
    $Script:SetAttackGroupExceptionsByPipeline = ($TestException | Set-AppSecPolicyAttackGroupExceptions -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -AttackGroupID $TestAttackGroupID -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPolicyAttackGroupExceptions by pipeline sets correctly' {
        $SetAttackGroupExceptionsByPipeline.exception | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyAttackGroupExceptions by body
    $Script:SetAttackGroupExceptionsByBody = Set-AppSecPolicyAttackGroupExceptions -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -AttackGroupID $TestAttackGroupID -Body $TestExceptionBody -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyAttackGroupExceptions by body sets correctly' {
        $SetAttackGroupExceptionsByBody.exception | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecPolicyAttackGroupExceptions
    $Script:AttackGroupExceptions = Get-AppSecPolicyAttackGroupExceptions -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -AttackGroupID $TestAttackGroupID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyAttackGroupExceptions returns the correct data' {
        $AttackGroupExceptions.exception | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyRuleExceptions by pipeline
    $Script:SetRuleExceptionsByPipeline = ($TestException | Set-AppSecPolicyRuleExceptions -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -RuleID $TestRuleID -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPolicyRuleExceptions by pipeline sets correctly' {
        $SetRuleExceptionsByPipeline.exception | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyRuleExceptions by body
    $Script:SetRuleExceptionsByBody = Set-AppSecPolicyRuleExceptions -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -RuleID $TestRuleID -Body $TestExceptionBody -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyRuleExceptions by body sets correctly' {
        $SetRuleExceptionsByBody.exception | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecPolicyRuleExceptions
    $Script:RuleExceptions = Get-AppSecPolicyRuleExceptions -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -RuleID $TestRuleID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyRuleExceptions returns the correct data' {
        $RuleExceptions.exception | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecPolicyMode
    $Script:PolicyMode = Get-AppSecPolicyMode -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyMode returns the correct data' {
        $PolicyMode.mode | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyMode
    $Script:SetPolicyMode = Set-AppSecPolicyMode -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -Mode ASE_MANUAL -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyMode sets correctly' {
        $SetPolicyMode.mode | Should -Not -BeNullOrEmpty
    }

    ### List-AppSecPolicyRules
    $Script:PolicyRules = List-AppSecPolicyRules -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecPolicyRules returns a list' {
        $PolicyRules.count | Should -BeGreaterThan 0
    }

    ### Get-AppSecPolicyRule
    $Script:Rule = Get-AppSecPolicyRule -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -RuleID $TestRuleID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyRule returns the correct data' {
        $Rule.action | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyRule
    $Script:SetRule = Set-AppSecPolicyRule -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -RuleID $TestRuleID -Action 'deny' -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyRule updates correctly' {
        $SetRule.action | Should -Be 'deny'
    }

    ### Update-AppSecKRSRuleSet
    $Script:KRSRuleSet = Update-AppSecKRSRuleSet -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -Mode $TestPolicyMode -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Update-AppSecKRSRuleSet sets correctly' {
        $KRSRuleSet.mode | Should -Be $TestPolicyMode
    }

    ### Get-AppSecPolicyAdaptiveIntelligence
    $Script:AdaptiveIntel = Get-AppSecPolicyAdaptiveIntelligence -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyAdaptiveIntelligence returns the correct data' {
        $AdaptiveIntel.threatIntel | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyAdaptiveIntelligence
    $Script:SetAdaptiveIntel = Set-AppSecPolicyAdaptiveIntelligence -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -Action on -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyAdaptiveIntelligence updates correctly' {
        $SetAdaptiveIntel.threatIntel | Should -Be 'on'
    }

    ### Get-AppSecPolicyUpgradeDetails
    $Script:UpgradeDetails = Get-AppSecPolicyUpgradeDetails -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyUpgradeDetails returns the correct data' {
        $UpgradeDetails.current | Should -Not -BeNullOrEmpty
    }

    #************************************************#
    #                WAF Evaluation                  #
    #************************************************#

    ### Set-AppSecPolicyEvaluationMode
    $Script:EvalMode = Set-AppSecPolicyEvaluationMode -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -Mode START -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyEvaluationMode returns the correct data' {
        $EvalMode.eval | Should -Be 'enabled'
    }

    ### List-AppSecPolicyEvaluationRules
    $Script:EvalPolicyRules = List-AppSecPolicyEvaluationRules -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecPolicyEvaluationRules returns a list' {
        $EvalPolicyRules.count | Should -BeGreaterThan 0
    }

    ### Get-AppSecPolicyEvaluationRule
    $Script:EvalRule = Get-AppSecPolicyEvaluationRule -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -RuleID $TestRuleID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyEvaluationRule returns the correct data' {
        $EvalRule.action | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyEvaluationRule
    $Script:EvalSetRule = Set-AppSecPolicyEvaluationRule -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -RuleID $TestRuleID -Action 'deny' -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyEvaluationRule updates correctly' {
        $EvalSetRule.action | Should -Be 'deny'
    }

    ### List-AppSecPolicyEvaluationAttackGroups
    $Script:EvalAttackGroups = List-AppSecPolicyEvaluationAttackGroups -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecPolicyEvaluationAttackGroups returns the correct data' {
        $EvalAttackGroups.count | Should -BeGreaterThan 0
    }

    ### Get-AppSecPolicyEvaluationAttackGroup
    $Script:EvalAttackGroup = Get-AppSecPolicyEvaluationAttackGroup -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -AttackGroupID $AttackGroups[0].group -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyEvaluationAttackGroup returns the correct data' {
        $EvalAttackGroup.action | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyEvaluationAttackGroup
    $Script:EvalSetAttackGroup = Set-AppSecPolicyEvaluationAttackGroup -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -AttackGroupID $AttackGroups[0].group -Action "deny" -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyEvaluationAttackGroup sets correctly' {
        $EvalSetAttackGroup.action | Should -Be "deny"
    }

    ### Set-AppSecPolicyEvaluationAttackGroupExceptions by pipeline
    $Script:EvalSetAttackGroupExceptionsByPipeline = ($TestException | Set-AppSecPolicyEvaluationAttackGroupExceptions -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -AttackGroupID $TestAttackGroupID -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPolicyEvaluationAttackGroupExceptions by pipeline sets correctly' {
        $EvalSetAttackGroupExceptionsByPipeline.exception | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyEvaluationAttackGroupExceptions by body
    $Script:EvalSetAttackGroupExceptionsByBody = Set-AppSecPolicyEvaluationAttackGroupExceptions -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -AttackGroupID $TestAttackGroupID -Body $TestExceptionBody -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyEvaluationAttackGroupExceptions by body sets correctly' {
        $EvalSetAttackGroupExceptionsByBody.exception | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecPolicyEvaluationAttackGroupExceptions
    $Script:EvalAttackGroupExceptions = Get-AppSecPolicyEvaluationAttackGroupExceptions -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -AttackGroupID $TestAttackGroupID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyEvaluationAttackGroupExceptions returns the correct data' {
        $EvalAttackGroupExceptions.exception | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyEvaluationRuleExceptions by pipeline
    $Script:EvalSetRuleExceptionsByPipeline = ($TestException | Set-AppSecPolicyEvaluationRuleExceptions -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -RuleID $TestRuleID -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-AppSecPolicyEvaluationRuleExceptions by pipeline sets correctly' {
        $EvalSetRuleExceptionsByPipeline.exception | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyEvaluationRuleExceptions by body
    $Script:EvalSetRuleExceptionsByBody = Set-AppSecPolicyEvaluationRuleExceptions -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -RuleID $TestRuleID -Body $TestExceptionBody -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-AppSecPolicyEvaluationRuleExceptions by body sets correctly' {
        $EvalSetRuleExceptionsByBody.exception | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecPolicyEvaluationRuleExceptions
    $Script:EvalRuleExceptions = Get-AppSecPolicyEvaluationRuleExceptions -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -RuleID $TestRuleID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecPolicyEvaluationRuleExceptions returns the correct data' {
        $EvalRuleExceptions.exception | Should -Not -BeNullOrEmpty
    }

    #************************************************#
    #               Penalty Box Evaluation           #
    #************************************************#

    # ### Get-AppSecPolicyEvaluationPenaltyBox
    # $Script:EvalPenaltyBox = Get-AppSecPolicyEvaluationPenaltyBox -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section
    # it 'Get-AppSecPolicyEvaluationPenaltyBox returns the correct data' {
    #     $EvalPenaltyBox.penaltyBoxProtection | Should -Not -BeNullOrEmpty
    # }

    # ### Set-AppSecPolicyEvaluationPenaltyBox by pipeline
    # $Script:EvalSetPenaltyBoxByPipeline = ($PenaltyBox | Set-AppSecPolicyEvaluationPenaltyBox -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section)
    # it 'Set-AppSecPolicyEvaluationPenaltyBox by pipeline updates correctly' {
    #     $EvalSetPenaltyBoxByPipeline.penaltyBoxProtection | Should -Not -BeNullOrEmpty
    # }

    # ### Set-AppSecPolicyEvaluationPenaltyBox by body
    # $Script:EvalSetPenaltyBoxByBody = Set-AppSecPolicyEvaluationPenaltyBox -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -Body (ConvertTo-Json -Depth 10 $PenaltyBox) -EdgeRCFile $EdgeRCFile -Section $Section
    # it 'Set-AppSecPolicyEvaluationPenaltyBox by body updates correctly' {
    #     $EvalSetPenaltyBoxByBody.penaltyBoxProtection | Should -Not -BeNullOrEmpty
    # }

    #************************************************#
    #                     Export                     #
    #************************************************#

    ### Export-AppSecConfigurationVersionDetails
    $Script:Export = Export-AppSecConfigurationVersionDetails -ConfigID $NewConfig.configId -VersionNumber 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Export-AppSecConfigurationVersionDetails exports correctly' {
        $Export.configId | Should -Be $Newconfig.configId
    }
    
    #************************************************#
    #                  SIEM Versions                 #
    #************************************************#

    ### Export-AppSecConfigurationVersionDetails
    $Script:SiemVersions = Get-AppSecSiemVersions -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecSiemVersions returns the correct data' {
        $SiemVersions[0].id | Should -Not -BeNullOrEmpty
    }

    #************************************************#
    #                    Versions                    #
    #************************************************#

    ### List-AppSecConfigurationVersions
    $Script:Versions = List-AppSecConfigurationVersions -ConfigID $NewConfig.configId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AppSecConfigurationVersions returns a list' {
        $Versions[0].configId | Should -Be $NewConfig.ConfigId
    }

    ### New-AppSecConfigurationVersion
    $Script:NewVersion = New-AppSecConfigurationVersion -ConfigID $NewConfig.configId -CreateFromVersion 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-AppSecConfigurationVersion creates a new version' {
        $NewVersion.configId | Should -Be $NewConfig.ConfigId
    }

    ### Get-AppSecConfigurationVersion
    $Script:GetVersion = Get-AppSecConfigurationVersion -ConfigID $NewConfig.configId -VersionNumber $NewVersion.version -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AppSecConfigurationVersion gets the right version' {
        $GetVersion.version | Should -Be $NewVersion.version
    }

    ### Remove-AppSecConfigurationVersion
    it 'Remove-AppSecConfigurationVersion completes successfully' {
        { $Script:RemoveVersion = Remove-AppSecConfigurationVersion -ConfigID $NewConfig.configId -VersionNumber $NewVersion.version -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    #************************************************#
    #                    Removals                    #
    #************************************************#

    ### Remove-AppSecMatchTarget
    it 'Remove-AppSecMatchTarget completes successfully' {
        { Remove-AppSecMatchTarget -ConfigID $NewConfig.configId -VersionNumber 1 -TargetID $NewMatchTarget.targetId -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    ### Remove-AppSecPolicy
    it 'Remove-AppSecPolicy completes successfully' {
        { Remove-AppSecPolicy -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    ### Remove-AppSecReputationProfile
    it 'Remove-AppSecReputationProfile completes successfully' {
        { Remove-AppSecReputationProfile -ConfigID $NewConfig.configId -VersionNumber 1 -ReputationProfileID $NewReputationProfileByBody.id -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    ### Remove-AppSecCustomDenyAction
    it 'Get-AppSecCustomDenyAction completes successfully' {
        { Remove-AppSecCustomDenyAction -ConfigID $NewConfig.configId -VersionNumber 1 -CustomDenyID $NewCustomDenyAction.id -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    ### Remove-AppSecCustomRule
    it 'Remove-AppSecCustomRule completes successfully' {
        { Remove-AppSecCustomRule -ConfigID $NewConfig.ConfigId -RuleID $NewCustomRule.id -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    ### Remove-AppSecRatePolicy
    it 'Remove-AppSecRatePolicy completes successfully' {
        { Remove-AppSecRatePolicy -ConfigID $NewConfig.configId -VersionNumber 1 -RatePolicyID $NewRatePolicyByBody.id -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    ### Remove-AppSecConfiguration
    it 'Remove-AppSecConfiguration completes successfully' {
        { Remove-AppSecConfiguration -ConfigID $NewConfig.ConfigId -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    AfterAll {
    }
    
}

Describe 'Unsafe AppSec Tests' {

    #************************************************#
    #                   Activations                  #
    #************************************************#

    ### Activate-AppSecConfigurationVersion
    $Script:Activate = Activate-AppSecConfiguration -ConfigID 12345 -VersionNumber 1 -Network STAGING -NotificationEmails 'mail@example.com' -Note 'testing' -EdgeRCFile $SafeEdgeRcFile -Section $Section
    it 'Activate-AppSecConfigurationVersion activates correctly' {
        $Activate.activationId | Should -Not -BeNullOrEmpty
    }

    ### List-AppSecActivationHistory
    $Script:Activations = List-AppSecActivationHistory -ConfigID 12345 -EdgeRCFile $SafeEdgeRcFile -Section $Section
    it 'List-AppSecActivationHistory returns a list' {
        $Activations.count | Should -BeGreaterThan 0
    }

    ### Get-AppSecActivationRequestStatus
    $Script:ActivationRequest = Get-AppSecActivationRequestStatus -StatusID 'f81c92c5-b150-4c41-9b53-9cef7969150a' -EdgeRCFile $SafeEdgeRcFile -Section $Section
    it 'Get-AppSecActivationRequestStatus returns the correct data' {
        $ActivationRequest.statusId | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecActivationStatus
    $Script:ActivationStatus = Get-AppSecActivationStatus -ActivationID 1234 -EdgeRCFile $SafeEdgeRcFile -Section $Section
    it 'Get-AppSecActivationStatus returns the correct data' {
        $ActivationStatus.activationId | Should -Not -BeNullOrEmpty
    }

    #************************************************#
    #                  Subscriptions                 #
    #************************************************#

    ### List-AppSecSubscribers
    $Script:Subscribers = List-AppSecSubscribers -ConfigID 12345 -Feature AAG_TUNING_REC -EdgeRCFile $SafeEdgeRcFile -Section $Section
    it 'List-AppSecSubscribers returns a list' {
        $Subscribers.count | Should -BeGreaterThan 0
    }

    ### New-AppSecSubscription
    it 'New-AppSecSubscription completes successfully' {
        { New-AppSecSubscription -ConfigID 12345 -Feature AAG_TUNING_REC -Subscribers "email@example.com, email2@example.com" -EdgeRCFile $SafeEdgeRcFile -Section $Section } | Should -Not -Throw
    }

    ### Remove-AppSecSubscription
    it 'Remove-AppSecSubscription completes successfully' {
        { Remove-AppSecSubscription -ConfigID 12345 -Feature AAG_TUNING_REC -Subscribers "email@example.com, email2@example.com" -EdgeRCFile $SafeEdgeRcFile -Section $Section } | Should -Not -Throw
    }

    #************************************************#
    #             Tuning Recommendations             #
    #************************************************#
    
    ### Get-AppSecPolicyTuningRecommendations
    $Script:Recommendations = Get-AppSecPolicyTuningRecommendations -ConfigID 12345 -VersionNumber 1 -PolicyID EX01_123456 -EdgeRCFile $SafeEdgeRcFile -Section $Section
    it 'Get-AppSecPolicyTuningRecommendations returns a list' {
        $Recommendations.ruleRecommendations | Should -Not -BeNullOrEmpty
    }

    ### Set-AppSecPolicyTuningRecommendations
    it 'Set-AppSecPolicyTuningRecommendations completes successfully' {
        { Set-AppSecPolicyTuningRecommendations -ConfigID 12345 -VersionNumber 1 -PolicyID EX01_123456 -Action ACCEPT -SelectorID 84220 -EdgeRCFile $SafeEdgeRcFile -Section $Section } | Should -Not -Throw
    }

    ### Get-AppSecPolicyAttackGroupRecommendations
    $Script:AttackGroupRecommendations = Get-AppSecPolicyAttackGroupRecommendations -ConfigID 12345 -VersionNumber 1 -PolicyID EX01_123456 -AttackGroupID CMD -EdgeRCFile $SafeEdgeRcFile -Section $Section
    it 'Get-AppSecPolicyAttackGroupRecommendations returns a list' {
        $AttackGroupRecommendations.group | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecPolicyRuleRecommendations
    $Script:RuleRecommendations = Get-AppSecPolicyRuleRecommendations -ConfigID 12345 -VersionNumber 1 -PolicyID EX01_123456 -RuleID 12345 -EdgeRCFile $SafeEdgeRcFile -Section $Section
    it 'Get-AppSecPolicyRuleRecommendations returns a list' {
        $RuleRecommendations.id | Should -Not -BeNullOrEmpty
    }

}

# SIG # Begin signature block
# MIIpogYJKoZIhvcNAQcCoIIpkzCCKY8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAhhdbbNQ9YEmM+
# FZkgc/ZcqKDjEim8S+U5BZOrrMoq8qCCDo4wggawMIIEmKADAgECAhAIrUCyYNKc
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
# BgkqhkiG9w0BCQQxIgQgBri0aupHgXuvDuslBUf5xytEcp0M0likOyO9uFKKJgcw
# DQYJKoZIhvcNAQEBBQAEggIAkS9eEjwaqRrKwCmFbD7S1yOIn8MCrRiux3lbS5MK
# T12cSLR9Kw4VPSvb7YxG5uKYB/0f8oPxeyc2TgFx89RtgQx0uFYVZJ6Y/HEXL6i1
# FbRQBQqMQW445zSlNC5dkCubBL5SMeOvKmoECd/isqCuhMWBkG+j+1/eDZHPfEmu
# YIQVyxYGdHrot7wqQ85rEXPk9v7xL4KAheoBIxD9anUuffc6FASjH2Cz68bSc1Dx
# QVauQOOpZJAAcXWybBUqJzOZPKATsJJGKi26ssqUWHZRC3ZDHBaWId88MRJzT8dF
# d6oqZQ6mGSqOhYw4XdszYNC1fGiUoGsh7IQptfjMBjs2HS3nZZu4s7rlrH2MZao6
# rYa4sEVSWDzGdsLif0Xs2Zm44rWHliY1ut+Gc0/9nNZchiuQO/1H/yN9nwwR2cZk
# geden3gNLdjaGMx8nziA8JM990TpgOx2W95Z5EWbfYodgiUsZB6V12Kng+1JzgoR
# QgWEQkfTzNuwiWn36TXIv6NpO/YMts3NMrCfwfU5ro6W4WdeSHKFozMgcxiSjey/
# f/a4CYYpgQRNSmkLyEVeJH8NCw/x0eAZB5C0U8HgDtyf9jn3dpD9OJVUa8NrQKAf
# BuoDA+7AWBUIIrmHo1AabD/pEnDG1kZEl1hlQqw9xiRbIulvGTuGzXFoyHWUKLGg
# DRuhghdAMIIXPAYKKwYBBAGCNwMDATGCFywwghcoBgkqhkiG9w0BBwKgghcZMIIX
# FQIBAzEPMA0GCWCGSAFlAwQCAQUAMHgGCyqGSIb3DQEJEAEEoGkEZzBlAgEBBglg
# hkgBhv1sBwEwMTANBglghkgBZQMEAgEFAAQgAPzx5CIMol03YXkjgU5O3bFrMz+K
# KgjqVK9hPBdbKWwCEQC8ObUubJEfw+dOR+kDBI1pGA8yMDIzMTEwNjE3MTExNVqg
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
# DQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcNAQkFMQ8XDTIzMTEwNjE3MTExNVowKwYL
# KoZIhvcNAQkQAgwxHDAaMBgwFgQUZvArMsLCyQ+CXc6qisnGTxmcz0AwLwYJKoZI
# hvcNAQkEMSIEIAnBno9gBq1e6/2Z3QRCx4TLYChZN7aAUfNerP7SlYs5MDcGCyqG
# SIb3DQEJEAIvMSgwJjAkMCIEINL25G3tdCLM0dRAV2hBNm+CitpVmq4zFq9NGprU
# DHgoMA0GCSqGSIb3DQEBAQUABIICAAk1Z+yLt/5AGUWW6H8O6eJfMP0D8QoOaJWf
# 7Bi2eDtv6pYTrf81fNDX5cE3Vw/YVoopNNAY4O4sTmjEZbLGL9Qm3EIPBEEqNeMN
# lBWq+hEi+OAaZTQBqD0xPkpJU2Xa45pLzWzCs2hsqpEVHp7z2rDl0bp0u9PhRNvJ
# T1O6TifwdBpK03/ucs+RWisz8Q2YC4p1MBK4rAjHXT2+TgI2yr67TnI7SlS0K7YK
# oeM2ZmhrMIASN9zFNRav+++9Ah5/JTz4wTtODv8dwuMdbuNjlh3RNWDaY9NXalZw
# wBMxbHM78eJej2lFXaqAzM6OXtJ/M7ze0REuKGQiXHj/lKnJnohuE7Zmlgu/uZeF
# 255pPp2qD0/600NBDfRkDssA1kTYtGqhKJcVfKXfHxBccu4BANJwIRywTxraR8jz
# lPRGwvRt3OaUWKLwd+uZT/g5qihqVzKv5amtQuOHo7OX2EiJOVMuzLucupGWMnIq
# iKJezv1jToEmP0s/ATOSMRzTUT58NaIX0mDXIR2lvbdM/oQWCGE6ohu8Hylnl14N
# W8cMjwAHx8N0rGyzQ1nPMmaFAN0lcYe8qq4XJ4uWiNbiZjBrfCustQXmGIJ6veOr
# cTHmLr7zu2oUtzidNhoPdxwsY0ThE9UdREAtW0JEGLhTQsK2S2TTmcKSYLmnCVqo
# qb3YByGl
# SIG # End signature block
