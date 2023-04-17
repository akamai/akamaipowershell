Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestContract = '1-1NC95D'
$Script:TestGroupName = 'AkamaiPowershell'
$Script:TestReportType = 'load-balancing-dns-traffic-by-datacenter'

Describe 'Safe Reporting Tests' {
    BeforeDiscovery {
        
    }

    ### List-ReportTypes
    $Script:ReportTypes = List-ReportTypes -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-ReportTypes returns a list' {
        $ReportTypes.count | Should -Not -Be 0
    }

    ### List-ReportTypeVersions
    $Script:Versions = List-ReportTypeVersions -ReportType $TestReportType -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-ReportTypeVersions returns a list' {
        $Versions.count | Should -Not -Be 0
    }

    ### List-ReportTypeVersions
    $Script:Report = Get-ReportType -ReportType $TestReportType -Version $Versions[0].Version -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-ReportType returns the correct data' {
        $Report.name | Should -Be $TestReportType
    }

    AfterAll {
        
    }
    
}

Describe 'Unsafe Reporting Tests' {
    ### Get-CacheableReport
    $Script:CacheableReport = Get-CacheableReport -ReportType hits-by-time -Version 1 -Start 2022-12-21T00:00:00Z -End 2022-12-22T00:00:00Z -Interval HOUR -ObjectIds 123456 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-CacheableReport gets some data' {
        $CacheableReport.data.count | Should -Not -Be 0
    }

    ### Generate-Report
    $Script:NonCacheableReport = Generate-Report -ReportType hits-by-time -Version 1 -Start 2022-12-21T00:00:00Z -End 2022-12-22T00:00:00Z -Interval HOUR -ObjectIDs 123456 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Generate-Report gets some data' {
        $NonCacheableReport.data.count | Should -Not -Be 0
    }

}
