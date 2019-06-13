Describe "Network Lists Tests" {
    # Setup shared variables
    $EdgeRC = $env:PesterEdgeRC
    $Section = "default"

    $NetworkLists = List-NetworkLists -EdgeRCFile $EdgeRC -Section $Section
    $NetworkList = Get-NetworkList -NetworkListID $NetworkLists[0].uniqueId -EdgeRCFile $EdgeRC -Section $Section

    it "List-NetworkLists should list network lists" {
        $NetworkLists.count | Should -BeGreaterThan 0
    }

    it "Get-Network list should get a network list" {
        $NetworkList.uniqueId | Should -not -BeNullOrEmpty
    }
}