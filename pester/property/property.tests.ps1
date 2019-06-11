Import-Module ..\..\AkamaiPowershell.psm1

Describe "PAPI Tests" {
    it "List-Properties lists properties" {
        $Result = List-Properties -GroupID $env:PesterGroupID -ContractId $env:PesterContractID -EdgeRCFile $env:PesterEdgeRC -Section default
        $Result.count | Should -BeGreaterThan 0
    }

    it "Get-AccountID gets an account ID" {
        $Result = Get-AccountID -EdgeRCFile $env:PesterEdgeRC -Section default
        $Result | Should -Not -BeNullOrEmpty
    }

    it "Get-GroupDetails gets group details" {
        $Result = Get-GroupDetails -GroupName $Env:PesterGroupName -EdgeRCFile $env:PesterEdgeRC -Section default
        $Result.groupName | Should -Exist
    }
}