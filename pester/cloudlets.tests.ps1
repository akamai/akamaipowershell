Describe "Cloudlets Tests" {
    # Setup shared variables
    $EdgeRC = $env:PesterEdgeRC
    $Section = "default"

    $Cloudlets = List-Cloudlets -EdgeRCFile $EdgeRC -Section $Section
    $Cloudlet = Get-Cloudlet -CloudletID $Cloudlets[0].cloudletId -EdgeRCFile $EdgeRC -Section $Section
    $CloudletPolicies = List-CloudletPolicies -EdgeRCFile $EdgeRC -Section $Section
    $CloudletPolicy = Get-CloudletPolicy -PolicyID $CloudletPolicies[0].policyId -EdgeRCFile $EdgeRC -Section $Section
    $CloudletPolicyVersions = List-CloudletPolicyVersions -PolicyID $CloudletPolicy.policyId -EdgeRCFile $EdgeRC -Section $Section
    $CloudletPolicyVersion = Get-CloudletPolicyVersion -PolicyID $CloudletPolicy.policyId -Version $CloudletPolicyVersions[0].version -EdgeRCFile $EdgeRC -Section $Section
    $CloudletGroups = List-CloudletGroups -EdgeRCFile $EdgeRC -Section $Section
    $CloudletGroup = Get-CloudletGroup -GroupID $CloudletGroups[0].groupId -EdgeRCFile $EdgeRC -Section $Section

    it "List-Cloudlets lists cloudlets" {
        $Cloudlets.count | Should -BeGreaterThan 0
    }

    it "Get-Cloudlet gets a cloudlet" {
        $Cloudlet.cloudletName | Should -not -BeNullOrEmpty
    }

    it "List-CloudletPolicies lists cloudlet policies" {
        $CloudletPolicies.count | Should -BeGreaterThan 0
    }

    it "Get-CloudletPolicy gets a cloudlet policy" {
        $CloudletPolicy.name | Should -not -BeNullOrEmpty
    }

    it "List-CloudletPolicyVersions lists cloudlet policy versions" {
        $CloudletPolicyVersions.count | Should -BeGreaterThan 0
    }

    it "Get-CloudletPolicyVersion gets a cloudlet policy version" {
        $CloudletPolicyVersion.version | Should -not -BeNullOrEmpty
    }

    it "List-CloudletGroups lists cloudlet groups" {
        $CloudletGroups.count | Should -BeGreaterThan 0
    }

    it "Get-CloudletGroup gets a cloudlet group" {
        $CloudletGroup.groupName | Should -not -BeNullOrEmpty
    }
}