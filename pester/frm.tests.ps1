Describe "Firewall Rules Manager Tests" {
    # Setup shared variables
    $EdgeRC = $env:PesterEdgeRC
    $Section = "default"

    $FRMServices = List-FRMServices -EdgeRCFile $EdgeRC -Section $Section
    $FRMService = Get-FRMService -ServiceID $FRMServices[0].serviceId -EdgeRCFile $EdgeRC -Section $Section
    $FRMCIDRBlocks = List-FRMCidrBlocks -EdgeRCFile $EdgeRC -Section $Section

    it "List-FRMServices lists firewall rules manager services" {
        $FRMServices.Count | Should -BeGreaterThan 0
    }

    it "Get-FRMService returns a service" {
        $FRMService.serviceId | Should -not -BeNullOrEmpty
    }

    it "List-FRMCIDRBlocks lists cidr blocks for all subscribed services" {
        $FRMCIDRBlocks.count | Should -BeGreaterThan 0
    }

}