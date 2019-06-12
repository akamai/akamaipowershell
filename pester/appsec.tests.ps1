Describe "AppSec Tests" {
    # Setup shared variables
    $EdgeRC = $env:PesterEdgeRC
    $Section = "default"

    $AppSecConfigurations = List-AppSecConfigurations -EdgeRCFile $EdgeRC -Section $Section
    $ConfigVersions = List-AppSecConfigurationVersions -ConfigID $AppSecConfigurations[0].id -EdgeRCFile $EdgeRC -Section $Section
    $Version = Get-AppSecConfigurationVersionDetails -ConfigID $AppSecConfigurations[0].id -VersionNumber $ConfigVersions[0].version -EdgeRCFile $EdgeRC -Section $Section

    it "Get-AppSecConfigurationVersionDetails gets version details" {
        $Version.version | Should -not -BeNullOrEmpty
    }

    it "List-AppSecConfigurations lists configs" {
        $ConfigVersions.count | Should -BeGreaterThan 0
    }

    it "List-AppSecConfigurations returns configs" {
        $AppSecConfigurations | Should -not -BeNullOrEmpty
    }


}