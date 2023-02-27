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
# MIIoaAYJKoZIhvcNAQcCoIIoWTCCKFUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+SlyDGp5E+v2Pc1DNdU5xHl6
# jauggiGYMIIFjTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0B
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
# MCMGCSqGSIb3DQEJBDEWBBSd4MPfsTQTNkjXvwyLyAojKRxDoTANBgkqhkiG9w0B
# AQEFAASCAgBC+uL2M8tZMJW3NYxSd3yeO+C+upRRs/6Z6HlOgS9RAm1yzxUogx2/
# 6qo+F235CGUkWrnhLYJDnFUVP2Q2eU++dTAkVqsCwGmANvI6iXEnPxHCJiuSNpyp
# Cq+N3l8fJZn3GEDqIB2iWlSOvwmCJvDQcUY63p98F+4KJ09xeVEktzBo4HXLPmYd
# BG6OZ73/Pgw6qgjymhHMNBDctGEbuiMFSAzcsXGtHSrcWnAvksgEtfXi+8ofiPkX
# R2mC9I3e0CUym9x58xhgWVVqjhUoA0tZbv8JLoZ6sgTj4YwM8Ppt/oVnusl+opz4
# RUZ6b+AZPRB5VokNahd6pvNkKwdFTiSKeLz7aND+yE/g8ikfJ+sWGksRm/elj80G
# ac1ZhPPUY9C+A/aj8r7CcSq16Fu4zjwDYc1OeMgadKrOZ+LK0jm6v20YBnJI83/5
# r7y/DGt9YxVbYqZQd575W5VMkxjDGAVih5jnSGszIIRi9ivNYSrG6AQgP8Y51u1W
# ssVNir7dgVKORaweSRhQV5d0BaFMQUVPcBLVpZ8M6D6mYpFxwEuQxcl51mm2TPvd
# rEoZRCN66kuz4DR5bbsqnpU9dxhSM/UvcR78hs3sR01YcfVMGuDicTx1IKV0qPRT
# p8FIheodba98UI2Ue39jI2EEdJBQtjecMbkVdCD6CHctQiuSN1aCYKGCAyAwggMc
# BgkqhkiG9w0BCQYxggMNMIIDCQIBATB3MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
# Ew5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBS
# U0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAxNaXJLlPo8Kko9KQeAPVow
# DQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqG
# SIb3DQEJBTEPFw0yMzAyMjcxNjI5MTBaMC8GCSqGSIb3DQEJBDEiBCDi2mTkpyd8
# BFv8fofh5k+SZmThv7PprOPu8VZhfB5PFDANBgkqhkiG9w0BAQEFAASCAgDPIC7/
# q1Fkbt/zbgJzqFe9IzM0jYiVNgo3CGk5L9hEdME0V225ZNwCOGpinMp0r8rpt0Ph
# ljXmPW1N4TfGgH0e6kGS06BsqlWMV5IqBs0YDa7oBBKiR3gjsD7psM3zx2ACxceF
# GLVy4x4tRcVqlhN0GHBJ4a7T3TkBao+AfDfEq3vrgehUjcFNigMeEuH2fXxbYQyf
# Uc6EJkvQCpAPq17paKGmcN+ZrT+VdzNsxvCS+xknC1N1iWYXbzecmXC+BGyVm8kL
# MxRwNKusFGKrTycrTtHl0q4lCGqxbL0paiQzdCs6Z22t2YCTn+7eUtEsbxP6rLlc
# D1/SKsxO4upbXRlVBF0rlwY4emakPIhNZxTVKQ8WMkBwKObr+Oc09yBXcHgMVHK8
# 0DvPyr6lrocRqZzYYWudxlJ9fUhpgF1kIHIq4jOpJooUayzZah75rUconG5lU552
# yEnpwt4M5/XEvdYdRZXE6F5rG8KlFnwhD27bnwtiwf51+oY6+6VRlQaNFjgnR1Mr
# 2gXl2ZcnycLSQcT084bxOEuRSsOi8gR0PupQKqXaru5N5IS3PCpfAoMVQcqc6exC
# NSMuwHGA/Un3KLODGDarxBrvXxj4syi6OVblMqICtqCfonuLKPUyhLz3XWc/RQI4
# oCMpJKe4WkKyY8AT5Be3P2ne4CSbSgx3bI4ZjA==
# SIG # End signature block
