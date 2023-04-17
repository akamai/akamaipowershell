Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestContract = '1-1NC95D'
$Script:TestGroupID = 209759
$Script:TestPolicyName = 'akamaipowershell'
$Script:TestPolicyDescription = 'Testing only'
$Script:TestCloudletType = 'FR'
$Script:TestMatchRulesJson = '[{"type":"frMatchRule","id":0,"name":"Test1","start":0,"end":0,"matchURL":null,"matches":[{"matchValue":"www.example.com","matchOperator":"equals","negate":false,"caseSensitive":false,"matchType":"hostname"}],"akaRuleId":"9c3679ff26421404","forwardSettings":{"originId":"originId1"}}]'
$Script:TestMatchRules = ConvertFrom-Json $TestMatchRulesJson

Describe 'Safe Cloudlets Tests' {

    BeforeDiscovery {

    }

    ### List-SharedCloudlets
    $Script:Cloudlets = List-SharedCloudlets -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-SharedCloudlets returns a list' {
        $Cloudlets.count | Should -Not -BeNullOrEmpty
    }

    ### List-SharedCloudletPolicies
    $Script:Policies = List-SharedCloudletPolicies -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-SharedCloudletPolicies returns a list' {
        $Policies.count | Should -Not -BeNullOrEmpty
    }

    ### New-SharedCloudletPolicy
    $Script:NewPolicy = New-SharedCloudletPolicy -Name $TestPolicyName -Description $TestPolicyDescription -GroupId $TestGroupID -CloudletType $TestCloudletType -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-SharedCloudletPolicy creates a policy' {
        $NewPolicy.name | Should -Be $TestPolicyName
    }

    ### Get-SharedCloudletPolicy
    $Script:Policy = Get-SharedCloudletPolicy -PolicyId $NewPolicy.id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-SharedCloudletPolicy finds the right policy' {
        $Policy.name | Should -Be $TestPolicyName
    }

    ### Set-SharedCloudletPolicy
    $Script:UpdatedPolicy = Set-SharedCloudletPolicy -PolicyId $NewPolicy.id -GroupID $TestGroupID -Description $TestPolicyDescription -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-SharedCloudletPolicy finds the right policy' {
        $UpdatedPolicy.description | Should -Be $TestPolicyDescription
    }

    ### New-SharedCloudletPolicyVersion by description and matchRules
    $Script:NewVersion = New-SharedCloudletPolicyVersion -PolicyID $NewPolicy.id -Description $TestPolicyDescription -MatchRules $TestMatchRules -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-SharedCloudletPolicyVersion creates version 1' {
        $NewVersion.version | Should -Be 1
    }

    ### List-SharedCloudletPolicyVersions
    $Script:Versions = List-SharedCloudletPolicyVersions -PolicyID $NewPolicy.id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-SharedCloudletPolicyVersions lists versions' {
        $Versions.count | Should -Not -Be 0
    }

    ### Get-SharedCloudletPolicyVersion
    $Script:Version = Get-SharedCloudletPolicyVersion -PolicyID $NewPolicy.id -Version 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-SharedCloudletPolicyVersion gets version 1' {
        $Version.policyId | Should -Be $NewPolicy.id
    }

    ### New-SharedCloudletPolicyVersion by pipeline
    $Script:NewVersionByPipeline = ($Version | New-SharedCloudletPolicyVersion -PolicyID $NewPolicy.id -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'New-SharedCloudletPolicyVersion by pipeline creates a new version' {
        $NewVersionByPipeline.version | Should -Be ($Version.version + 1)
    }

    ### New-SharedCloudletPolicyVersion by params
    $Script:NewVersionByParams = New-SharedCloudletPolicyVersion -PolicyID $NewPolicy.id -Description $TestPolicyDescription -MatchRules $Version.matchRules -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-SharedCloudletPolicyVersion by params creates a new version' {
        $NewVersionByParams.version | Should -Be ($NewVersionByPipeline.version + 1)
    }

    ### New-SharedCloudletPolicyVersion by body
    $Script:NewVersionByBody = New-SharedCloudletPolicyVersion -PolicyID $NewPolicy.id -Body (ConvertTo-Json -depth 100 $Version) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-SharedCloudletPolicyVersion by body creates a new version' {
        $NewVersionByBody.version | Should -Be ($NewVersionByParams.version + 1)
    }

    ### Set-SharedCloudletPolicyVersion by pipeline
    $Script:SetVersionByPipeline = ($Version | Set-SharedCloudletPolicyVersion -PolicyID $NewPolicy.id -Version latest -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-SharedCloudletPolicyVersion by pipeline updates correctly' {
        $SetVersionByPipeline.policyId | Should -Be $NewPolicy.id
    }

    ### Set-SharedCloudletPolicyVersion by params
    $Script:SetVersionByParams = Set-SharedCloudletPolicyVersion -PolicyID $NewPolicy.id -Version latest -Description $TestPolicyDescription -MatchRules $Version.matchRules -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-SharedCloudletPolicyVersion by params updates correctly' {
        $SetVersionByParams.policyId | Should -Be $NewPolicy.id
    }

    ### Set-SharedCloudletPolicyVersion by body
    $Script:SetVersionByBody = Set-SharedCloudletPolicyVersion -PolicyID $NewPolicy.id -Version latest -Body (ConvertTo-Json -depth 100 $Version) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-SharedCloudletPolicyVersion by body updates correctly' {
        $SetVersionByBody.policyId | Should -Be $NewPolicy.id
    }

    ### Remove-SharedCloudletPolicy
    it 'Remove-SharedCloudletPolicy succeeds' {
        { Remove-SharedCloudletPolicy -PolicyId $NewPolicy.id -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    AfterAll {
        
    }
    
}

Describe 'Unsafe Cloudlets Tests' {
    ### List-SharedCloudletPolicyActivations
    $Script:Activations = List-SharedCloudletPolicyActivations -PolicyID 1001 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'List-SharedCloudletPolicyActivations returns a list' {
        $Activations[0].id | Should -Not -BeNullOrEmpty
    }

    ### Activate-SharedCloudletPolicy
    $Script:ActivateResult = Activate-SharedCloudletPolicy -PolicyID 1001 -Version 1 -Network PRODUCTION -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Activate-SharedCloudletPolicy completes successfully' {
        $ActivateResult.operation | Should -Be 'ACTIVATION'
    }

    ### Get-SharedCloudletPolicyActivation
    $Script:ActivateResult = Get-SharedCloudletPolicyActivation -PolicyID 1001 -ActivationID 3001 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Activate-SharedCloudletPolicy completes successfully' {
        $ActivateResult.operation | Should -Be 'ACTIVATION'
    }
    
}
