Describe "Edge Hostname API (HAPI) tests" {
    # Setup shared variables
    $EdgeRC = $env:PesterEdgeRC
    $Section = "default"

    $EdgeHostnames = List-EdgeHostnames -EdgeRCFile $EdgeRC -Section $Section

    it "List-EdgeHostnames should list edge hostnames" {
        $EdgeHostnames.count | Should -BeGreaterThan 0
    }
}