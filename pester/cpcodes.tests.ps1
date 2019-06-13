Describe "Cloudlets Tests" {
    # Setup shared variables
    $EdgeRC = $env:PesterEdgeRC
    $Section = "default"

    $CPCodes = List-CPCodes -EdgeRCFile $EdgeRC -Section $Section
    $CPCode = Get-CPCode -CPCode $CPCodes[0].cpcodeId -EdgeRCFile $EdgeRC -Section $Section

    it "List-CPCodes should list CP Codes" {
        $CPCodes.count | Should -BeGreaterThan 0
    }

    it "Get-CPCode should get a cp code" {
        $CPCode.cpcodeId | Should -not -BeNullOrEmpty
    }

}