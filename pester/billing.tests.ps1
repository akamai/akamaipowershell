Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestContract = '1-1NC95D'
$Script:TestReportingGroup = 123456
$Script:TestProduct = 'M-LC-84827'

Describe 'Safe Billing Tests' {

    BeforeDiscovery {

    }


    AfterAll {
        
    }
    
}

Describe 'Unsafe Billing Tests' {
    ### Get-ProductUsage
    $Script:Usage = Get-ProductUsage -ContractID $TestContract -Start 2022-01 -End 2022-12 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-ProductUsage returns the correct data' {
        $Usage.usagePeriods | Should -Not -BeNullOrEmpty
    }

    ### Get-ProductUsagePerDay by contract
    $Script:UsagePerDayByContract = Get-ProductUsagePerDay -ContractID $TestContract -ProductID $TestProduct -Month '2023-01' -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-ProductUsagePerDay by contract returns the correct data' {
        $UsagePerDayByContract.usagePeriods | Should -Not -BeNullOrEmpty
    }

    ### Get-ProductUsagePerDay by reporting group
    $Script:UsagePerDayByRG = Get-ProductUsagePerDay -ReportingGroupId $TestReportingGroup -ProductID $TestProduct -Month '2023-01' -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-ProductUsagePerDay by reporting group returns the correct data' {
        $UsagePerDayByRG.usagePeriods | Should -Not -BeNullOrEmpty
    }

    ### Get-ProductUsagePerMonth by contract
    $Script:UsagePerMonthByContract = Get-ProductUsagePerMonth -ReportingGroupId $TestReportingGroup -ProductID $TestProduct -Start 2022-01 -End 2022-12 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-ProductUsagePerMonth by contract returns the correct data' {
        $UsagePerMonthByContract.usagePeriods | Should -Not -BeNullOrEmpty
    }

    ### Get-ProductUsagePerDay by reporting group
    $Script:UsagePerMonthByRG = Get-ProductUsagePerMonth -ContractID $TestContract -ProductID $TestProduct -Start 2022-01 -End 2022-12 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-ProductUsagePerMonth by reporting group returns the correct data' {
        $UsagePerMonthByRG.usagePeriods | Should -Not -BeNullOrEmpty
    }
    
}
