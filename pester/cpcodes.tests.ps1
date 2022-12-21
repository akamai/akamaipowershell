Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestContract = '1-1NC95D'
$Script:TestCPCode = 1277303
$Script:TestReportingGroup = 243616
$Script:TestReportingGroupBody = '{
    "reportingGroupName": "akamaipowershell-testing",
    "contracts": [
      {
        "contractId": "1-1NC95D",
        "cpcodes": [
          {
            "cpcodeId": 1277303,
            "cpcodeName": "akamaipowershell-testing"
          }
        ]
      }
    ],
    "accessGroup": {
      "groupId": 209759,
      "contractId": "1-1NC95D"
    }
}'
$Script:TestReportingGroupObject = ConvertFrom-Json -Depth 10 $TestReportingGroupBody

Describe 'Safe CP Codes Tests' {

    BeforeDiscovery {
        
    }

    ### List-CPCodes
    $Script:CPCodes = List-CPCodes -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-CPCodes returns a list' {
        $CPCodes.count | Should -Not -Be 0
    }

    ### List-CPReportingGroups
    $Script:ReportingGroups = List-CPReportingGroups -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-CPReportingGroups returns a list' {
        $ReportingGroups.count | Should -Not -Be 0
    }

    ### List-CPCodeWatermarkLimits
    $Script:WatermarkLimits = List-CPCodeWatermarkLimits -ContractID $TestContract -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-CPCodeWatermarkLimits returns a list' {
        $WatermarkLimits.count | Should -Not -Be 0
    }

    ### Get-CPCode
    $Script:CPCode = Get-CPCode -CPCode $TestCPCode -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-CPCode returns the correct data' {
        $CPCode.cpcodeId | Should -Be $TestCPCode
    }

    ### Set-CPCode by pipeline
    $Script:SetByPipeline = ( $CPCode | Set-CPCode -CPCode $TestCPCode -EdgeRCFile $EdgeRCFile -Section $Section )
    it 'Set-CPCode by pipeline returns the correct data' {
        $SetByPipeline.cpcodeName | Should -Be $CPCode.cpCodeName
    }

    ### Set-CPCode by param
    $Script:SetByParam = Set-CPCode -CPCode $TestCPCode -CPCodeObject $CPCode -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-CPCode by param returns the correct data' {
        $SetByParam.cpcodeName | Should -Be $CPCode.cpCodeName
    }

    ### Set-CPCode by body
    $Script:SetByBody = Set-CPCode -CPCode $TestCPCode -Body (ConvertTo-Json -Depth 10 $CPCode) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-CPCode by body returns the correct data' {
        $SetByBody.cpcodeName | Should -Be $CPCode.cpCodeName
    }

    ### Rename-CPCode
    $Script:Rename = Rename-CPCode -CPCode $TestCPCode -NewName $CPCode.cpcodename -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Rename-CPCode returns the correct data' {
        $Rename.cpcodeName | Should -Be $CPCode.cpCodeName
    }

    ### Get-CPReportingGroup
    $Script:ReportingGroup = Get-CPReportingGroup -ReportingGroupID $TestReportingGroup -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-CPReportingGroup returns the correct data' {
        $ReportingGroup.reportingGroupId | Should -Be $TestReportingGroup
    }

    ### Set-CPReportingGroup by pipeline
    $Script:SetRGByPipeline = ( $ReportingGroup | Set-CPReportingGroup -ReportingGroupID $TestReportingGroup -EdgeRCFile $EdgeRCFile -Section $Section )
    it 'Set-CPReportingGroup by pipeline returns the correct data' {
        $SetRGByPipeline.reportingGroupName | Should -Be $ReportingGroup.reportingGroupName
    }

    ### Set-CPReportingGroup by param
    $Script:SetRGByParam = Set-CPReportingGroup -ReportingGroupID $TestReportingGroup -ReportingGroupObject $ReportingGroup -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-CPReportingGroup by param returns the correct data' {
        $SetRGByParam.reportingGroupName | Should -Be $ReportingGroup.reportingGroupName
    }

    ### Set-CPReportingGroup by body
    $Script:SetRGByBody = Set-CPReportingGroup -ReportingGroupID $TestReportingGroup -Body (ConvertTo-Json -Depth 10 $ReportingGroup) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-CPReportingGroup by body returns the correct data' {
        $SetRGByBody.reportingGroupName | Should -Be $ReportingGroup.reportingGroupName
    }

    AfterAll {
        
    }
    
}

Describe 'Unsafe CP Codes Tests' {
    ### New-CPReportingGroup
    $Script:NewReportingGroup = ( $TestReportingGroupObject | New-CPReportingGroup -EdgeRCFile $SafeEdgeRCFile -Section $Section )
    it 'New-CPReportingGroup returns the correct data' {
        $NewReportingGroup.reportingGroupName | Should -Not -BeNullOrEmpty
    }

    ### Remove-CPReportingGroup
    it 'Remove-CPReportingGroup completes successfully' {
        { Remove-CPReportingGroup -ReportingGroupID $TestReportingGroup -EdgeRCFile $SafeEdgeRCFile -Section $Section} | Should -Not -Throw
    }
}