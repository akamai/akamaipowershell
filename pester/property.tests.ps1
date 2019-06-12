Import-Module ..\..\AkamaiPowershell.psm1

Describe "PAPI Tests" {
    # Setup shared variables
    $EdgeRC = $env:PesterEdgeRC
    $Section = "default"

    $Contracts = List-Contracts -EdgeRCFile $EdgeRC -Section $Section
    $FirstContractId = $Contracts[0].contractId

    $Groups = List-Groups -EdgeRCFile $EdgeRC -Section $Section
    $TopLevelGroups = List-TopLevelGroups -EdgeRCFile $EdgeRC -Section $Section
    $FirstTopLevelGroupID = $TopLevelGroups[0].groupId
    $FirstTopLevelGroupName = $TopLevelGroups[0].groupName
    $Group = Get-Group -GroupID $FirstTopLevelGroupID -EdgeRCFile $EdgeRC -Section $Section

    $Properties = List-Properties -GroupID $FirstTopLevelGroupID -ContractId $FirstContractId -EdgeRCFile $EdgeRC -Section $Section
    $FirstPropertyID = $Properties[0].propertyId
    $Property = Get-Property -PropertyId $FirstPropertyID -EdgeRCFile $EdgeRC -Section $Section
    $RuleTree = Get-PropertyRuleTree -PropertyId $Property.propertyId -PropertyVersion $Property.latestVersion -EdgeRCFile $EdgeRC -Section $Section
    $PropertyVersion = Get-PropertyVersion -PropertyId $Property.propertyId -PropertyVersion $Property.latestVersion -EdgeRCFile $EdgeRC -Section $Section

    $AccountID = Get-AccountID -EdgeRCFile $EdgeRC -Section $Section
    $GroupByName = Get-GroupByName -GroupName $FirstTopLevelGroupName -EdgeRCFile $EdgeRC -Section $Section
    $LatestVersion = Get-LatestVersionOfProperty -PropertyId $FirstPropertyID -EdgeRCFile $EdgeRC -Section $Section
    $PapiCPCodes = List-PapiCPCodes -ContractId $FirstContractId -GroupId $FirstTopLevelGroupID -EdgeRCFile $EdgeRC -Section $Section
    $FirstPapiCPCode = $PapiCPCodes[0]
    $PapiEdges = List-PapiEdgeHostnames -GroupID $FirstTopLevelGroupID -ContractId $FirstContractId -EdgeRCFile $EdgeRC -Section $Section
    $FirstPapiEdge = $PapiEdges[0]
    $Products = List-Products -ContractId $FirstContractId -EdgeRCFile $EdgeRC -Section $Section
    $Activations = List-PropertyActivations -PropertyId $FirstPropertyID -EdgeRCFile $EdgeRC -Section $Section
    $FirstActivationID = $Activations[0].activationId
    $Activation = Get-PropertyActivation -PropertyId $FirstPropertyID -ActivationID $FirstActivationID -EdgeRCFile $EdgeRC -Section $Section
    $Hostnames = List-PropertyHostnames -PropertyVersion "latest" -PropertyId $FirstPropertyID -EdgeRCFile $EdgeRC -Section $Section
    $PropertyVersions = List-PropertyVersions -PropertyId $FirstPropertyID -EdgeRCFile $EdgeRC -Section $Section

    Write-Host "FirstPropertyID = $FirstPropertyID"
    Write-Host "FirstActivationID = $FirstActivationID"

    it "Get-AccountID gets an account ID" {
        $AccountID | Should -Not -BeNullOrEmpty
    }

    it "Get-Group gets a group" {
        $Group.groupId | Should -Not -BeNullOrEmpty
    }

    it "Get-GroupByName gets groups by name" {
        $GroupByName.groupName | Should -Not -BeNullOrEmpty
    }

    it "Get-LatestVersionOfPropery gets latest property version" {
        $LatestVersion | Should -Not -BeNullOrEmpty
    }

    it "Get-PapiCPCode gets CP Code" {
        $FirstPapiCPCode | Should -Not -BeNullOrEmpty
    }

    it "Get-PapiEdgeHostname gets CP hostname" {
        $FirstPapiEdge | Should -Not -BeNullOrEmpty
    }

    it "Get-Property gets property info" {
        $Property.propertyName | Should -Not -BeNullOrEmpty
    }

    it "Get-PropertyActivation gets activation info" {
        $Activation.activationId | Should -Not -BeNullOrEmpty
    }

    it "Get-PropertyRuleTree gets a rule tree" {
        $RuleTree.rules | Should -Not -BeNullOrEmpty
    }

    it "Get-PropertyVersion gets a version" {
        $PropertyVersion.propertyVersion | Should -Not -BeNullOrEmpty
    }

    it "List-Contracts lists contracts" {
        $Contracts.count | Should -BeGreaterThan 0
    }

    it "List-Groups lists groups" {
        $Groups.count | Should -BeGreaterThan 0
    }

    it "List-PapiCpCodes lists Papi CP Codes" {
        $PapiCPCodes.count | Should -BeGreaterThan 0
    }

    it "List-PapiEdgeHostnames lists Papi Edge Hostnames" {
        $PapiEdges.count | Should -BeGreaterThan 0
    }

    it "List-Products lists products" {
        $Products.count | Should -BeGreaterThan 0
    }

    it "List-Properties lists properties" {
        $Properties.count | Should -BeGreaterThan 0
    }

    it "List-PropertyActivations lists activations" {
        $Activations.count | Should -BeGreaterThan 0
    }

    it "List-PropertyHostnames lists hostnames" {
        $Hostnames.count | Should -BeGreaterThan 0
    }

    it "List-PropertyVersions lists versions" {
        $PropertyVersions.count | Should -BeGreaterThan 0
    }

    it "List-TopLevelGroups lists groups" {
        $TopLevelGroups.count | Should -BeGreaterThan 0
    }
}