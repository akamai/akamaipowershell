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
$Script:TestSiemSettingsBody ='{"enableSiem":true,"enableForAllPolicies":true, "siemDefinitionId": 1}'
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
        {$Script:FailoverHostnames = List-AppSecFailoverHostnames -ConfigID $NewConfig.configId -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
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
        {Remove-AppSecPolicy -ConfigID $NewConfig.configId -VersionNumber 1 -PolicyID $NewPolicy.policyId -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
    }

    ### Remove-AppSecReputationProfile
    it 'Remove-AppSecReputationProfile completes successfully' {
        { Remove-AppSecReputationProfile -ConfigID $NewConfig.configId -VersionNumber 1 -ReputationProfileID $NewReputationProfileByBody.id -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    ### Remove-AppSecCustomDenyAction
    it 'Get-AppSecCustomDenyAction completes successfully' {
        {Remove-AppSecCustomDenyAction -ConfigID $NewConfig.configId -VersionNumber 1 -CustomDenyID $NewCustomDenyAction.id -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
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
# MIIpowYJKoZIhvcNAQcCoIIplDCCKZACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAL/zQGYsF8M19J
# SZRJF+qJjb0/CI1n5gApZydCnfnnxKCCDpEwggawMIIEmKADAgECAhAIrUCyYNKc
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
# yK+p/pQd52MbOoZWeE4wggfZMIIFwaADAgECAhAJi6B8zycIi8m1Q3xkIZDnMA0G
# CSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjMwMTExMDAwMDAwWhcNMjMwMzAx
# MjM1OTU5WjCB3jETMBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8AgEC
# EwhEZWxhd2FyZTEdMBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEDAOBgNV
# BAUTBzI5MzM2MzcxCzAJBgNVBAYTAlVTMRYwFAYDVQQIEw1NYXNzYWNodXNldHRz
# MRIwEAYDVQQHEwlDYW1icmlkZ2UxIDAeBgNVBAoTF0FrYW1haSBUZWNobm9sb2dp
# ZXMgSW5jMSAwHgYDVQQDExdBa2FtYWkgVGVjaG5vbG9naWVzIEluYzCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBALFDEw1oBMbHbJBtOuHBaSg6zH1hMhdP
# WEtWOgnEO7TgO6LGXoRuP6gZmX844/W6kH+CRIMAzei+6AQ2AUzOAWH7ipwScikJ
# HPmxUWM/+yNWJLrnZtgOtPJalsqm3oTjCF/+WDGEVul5EMhlKb6WIg50gzWr3HbG
# 0ym564cdqZQJtn1k6m13FNtIIykgDuR9ttFdh1tsBBYOrSP6W1uu+NNpDBwr16nj
# SQtmqZTwgO+VZT/dNRvalW1a4vlAgN+U/Xo72aNqIiVnByFP2Gj6IWbUezNjgOFM
# kSe7u52cVu51GfL2XjKWup0X0gfluU06P3QZN+wiZFBfsdmXiGAXPd+UysAGUh1X
# J+2lnVQyHD9L1Qmw11wWD/pNYQIvjWdpzxU5NdaXEH/lbBouF+94C8HI74tyzsSW
# /E9mb+enLAebUp4jemguKMhsZC3WG2PhqlIdvPDWmaGmg6td5flco4W9xUkgf8Lp
# gYrCUaqWwQ/JXht0dl4ITqgJwHorK4MT2B3X0Ft+/cTHLxSBm8TcggwTEPXQHCiZ
# jbxuHNvAZQga7+0NC4cljUhbCbhLTe7gX+XAq9LwcAtlSzN/aVF6tpPMyCj/xuFC
# BjWtML079FoIST69sVfhdjFYUfS1goauFy+CqXda3Rgirv48tm11MmpgJf5uzFy9
# +sdRhWzLC66pAgMBAAGjggIFMIICATAfBgNVHSMEGDAWgBRoN+Drtjv4XxGG+/5h
# ewiIZfROQjAdBgNVHQ4EFgQULvUKZAEQ6oPpuyNAwiZsQgGlULIwDgYDVR0PAQH/
# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMIG1BgNVHR8Ega0wgaowU6BRoE+G
# TWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENvZGVT
# aWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3JsMFOgUaBPhk1odHRwOi8vY3Js
# NC5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JTQTQw
# OTZTSEEzODQyMDIxQ0ExLmNybDA9BgNVHSAENjA0MDIGBWeBDAEDMCkwJwYIKwYB
# BQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCBlAYIKwYBBQUHAQEE
# gYcwgYQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBcBggr
# BgEFBQcwAoZQaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcnQwDAYDVR0T
# AQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAulx9aewYZWl0UyqeAts4V+P06gcL
# f+4Hsnwtn8hAlqT8o+8hnPB5LplZCR3OJT98gIq6dXAvPQJWNq1pc/RD0OTIpEDs
# mqzw0c/OHPrnZcuxQxHojQe2J2Gx9E5u6AobLHFTz1+kmgQzRGyCMBecdPRWubXx
# TyL9SiHE2XN/oXZMBWQdmpl3a79wia495lO2rstz/VNCjX0Hc5FOo+ewExly4WfP
# qYmAVH1cJ3AKrh79dFJhgaeLd/+3szgImHJ8C7EsvobpwKPW9JGbNf6QnvQ/ZbTN
# dqAzedwtAziNw0F26+EKuf2P2VVBIHiepF51Dh+wSo8qA+A9NFxMb17zMXnNx8Xc
# Qd/dAULN3X7XT3J3OaSvxMKTMcboh0r5T3OLTy61KYGBa4UCYuVPrMCv0LjivCdq
# VRfWlZNTrsD0dOIUtpjrK/JLxpwRx0I50QQMsPzs5BJLHS+3ULv82xftwwfMbbLB
# ZicDSmLRN0HVzY0hfxTRwRJAKYmCdhSfH/IcwuKyn4kGeXIkaEtGYAhDvLfyxjXD
# d5VcQeScaq7x+EXW5wgISNwxf2kUFgthzEvDNObsnQ3Lr9TwPy/+5Lkj1Oa5Q2CE
# nALMLhFL55Cz7xHggTSuzdnNLmJPMXj0XwVbDITd0lVjQ9Vn7WNa4U38vn6Xjw+A
# 6gdW445gtFLdy/4xghpoMIIaZAIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
# Ew5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBD
# b2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTECEAmLoHzPJwiLybVD
# fGQhkOcwDQYJYIZIAWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
# FTAvBgkqhkiG9w0BCQQxIgQgJqm7QKX3RPDn7T5lyV27p99giBINK6XMFAT5iDJS
# mLcwDQYJKoZIhvcNAQEBBQAEggIAU4BsI4jB/LMYrJ0POzjYoIYeh4JnmSvLW1hn
# YMN+c88JkjwcsROG4TA3g8la/lpPPNokml7EryHfPoYWR6aoIaT21knV3hcqopzK
# ffTVk976ywbNjf/Z+amxzVG1WU1xdlrHPmbYjcuKMsbhFQ9hrGMBPYxalRZfiVzY
# 68np88yKWy6rBCAD75OWpqKTfgLQc57jyv1HQNUH+x3HyVsxre6mQmGQLx1i1KId
# uTybjANsbwdi4+l0qLIqaAwEYFhiKMTd0FOHBXwyq2XeKStcwUPgRXlg2BjMk1AX
# Q2WuZTsOuob1+VgFl0IaV7mOw/J7sJ3ZOYyywNKRgBACmlv8l1OJPK7FjU8Ro8j3
# FCFfjqm8z597oaz6lWhYmiWJu1kkZI2/CekQdERD9eKFDI3D+++1I8N8hbp/jbDF
# I06M3H9l1yjwCjiBNDTHI5XeSrOD0Uh5+5UbhG0eBIiYUmvTAN9mpWh/r4gjuORs
# hrf5uImEO+BAFP/xcUuKeALiPZ+yyZRSVca6csoy4K/kJkCE6Kp8vsSoizSuVrbQ
# JKs6CHnqq0eCuIKgyN3yoO0wu6Rw0/s15HIf3roGEvzGZty9iDPGyglGUrEpFvKo
# 4SFwyN8StJas0ZLatewl5NHZmW07+x9MDRI6GJD3iJjoXAJSf7+Y/5l8lhnUq2Y9
# bnEMgGWhghc+MIIXOgYKKwYBBAGCNwMDATGCFyowghcmBgkqhkiG9w0BBwKgghcX
# MIIXEwIBAzEPMA0GCWCGSAFlAwQCAQUAMHgGCyqGSIb3DQEJEAEEoGkEZzBlAgEB
# BglghkgBhv1sBwEwMTANBglghkgBZQMEAgEFAAQgkIbjmTeHFZlYBIkURakasXQV
# ZO5dW361ucjSZQ+bBnUCEQCR/wgPz22P+OgaFUeQg8QsGA8yMDIzMDEyNTE3MjMz
# MFqgghMHMIIGwDCCBKigAwIBAgIQDE1pckuU+jwqSj0pB4A9WjANBgkqhkiG9w0B
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
# MQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yMzAxMjUxNzIzMzBaMCsG
# CyqGSIb3DQEJEAIMMRwwGjAYMBYEFPOHIk2GM4KSNamUvL2Plun+HHxzMC8GCSqG
# SIb3DQEJBDEiBCAuKhRrPfvLLn0EgW24pc3W6cfqQ8IZ31b4kBwg2gi0DDA3Bgsq
# hkiG9w0BCRACLzEoMCYwJDAiBCDH9OG+MiiJIKviJjq+GsT8T+Z4HC1k0EyAdVeg
# I7W2+jANBgkqhkiG9w0BAQEFAASCAgA9Gj2xVezqxj9Qhgz1d64nIQHYw9TYXpy3
# wbkpFFESlO+mZsuoaB7Ylj/eAtNyqHK/+xPmJMpkqHQKc3hX2JB7hllRV5MOkgpl
# 4sZ4Rjp9k5MP/cK+aPmMcxEPgQIJ5ZqfW+Fg1Ph9gccnOdoPP3F+Fs9+ytBDM3WE
# Jvj3Hij/2+D+SL5s/CMkcrQxIraJY9aw41M2beIGcJn3AQkpXaKlFNDAfNF0+lXc
# MO1mitTrWH7xB0f0x7dCVJ+dNrEboGC0MhTQ+CFlNkflhNOOAtEQkr7h5PkFQrOT
# y1KGIf9/AA2dtip4OMmjlEpCJGr/HeiHIfyYEkgTMS4/awlbn9y+x6Q/4bBAMGuP
# 1TsEtF/v+75ob6wphPKw8ZUto8VxL4qFJfp/i/2AG0aUNm9N6ZGjy4XPb9VQWyd7
# ON7zKdzym1xGwk85qJlJi44FvWFVxfAAQCgNp92+qipkD3gL4N7QNRnxzE+aDsrh
# iV8ItuueEuDOaTnQ276gXY1kQXM1iQBITfkIFCOV7Ws16jUlAc8+RhcUp0hwGsdx
# XQrdDZN+eh7LN0myOl3piJz9k/IPVxpDRPaLbIHiqFCSfeDXHCP9KElxB16PviNQ
# nLCHooliXYlYNv+4KmWoovkdjpSB41BFsJy6oc61HvqKRXojupYh+1O6Lvqawv+4
# v1VzF1mpdw==
# SIG # End signature block
