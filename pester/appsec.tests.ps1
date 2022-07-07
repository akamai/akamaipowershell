Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestConfigName = "akamaipowershell"
$Script:TestConfigDescription = "Powershell pester testing. Will be deleted shortly."
$Script:TestContract = '1-1NC95D'
$Script:TestGroupID = 209759
$Script:TestHostnames = 'akamaipowershell-testing.edgesuite.net'
$Script:TestCustomRule = '{"conditions":[{"type":"pathMatch","positiveMatch":true,"value":["/test"],"valueCase":false,"valueIgnoreSegment":false,"valueNormalize":false,"valueWildcard":true}],"name":"cr1","operation":"AND","ruleActivated":false,"structured":true,"tag":["tag1"],"version":1}'

Describe 'Safe AppSec Tests' {
    BeforeDiscovery {
        ### New-AppSecConfiguration
        it 'New-AppSecConfiguration creates successfully' {
            $Script:NewConfig = New-AppSecConfiguration -Name $TestConfigName -Description $TestConfigDescription -GroupID $TestGroupID -ContractId $TestContract -Hostnames $TestHostnames -EdgeRCFile $EdgeRCFile -Section $Section
            $NewConfig.name | Should -Be $TestConfigName
        }

        ### New-AppSecCustomRule
        it 'New-AppSecCustomRule creates successfully' {
            $Script:NewCustomRule = New-AppSecCustomRule -ConfigID $NewConfig.configId -Body $TestCustomRule -EdgeRCFile $EdgeRCFile -Section $Section
            $NewCustomRule.id | Should -Not -BeNullOrEmpty
        }
    }

    ### List-AppSecConfigurations
    it 'List-AppSecConfigurations gets a list of configs' {
        $Script:Configs = List-AppSecConfigurations -EdgeRCFile $EdgeRCFile -Section $Section
        $Configs | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecConfiguration by Name
    it 'Get-AppSecConfiguration by Name finds the config' {
        $Script:Config = Get-AppSecConfiguration -ConfigName $TestConfigName -EdgeRCFile $EdgeRCFile -Section $Section
        $Config | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecConfiguration by ID
    it 'Get-AppSecConfiguration by ID finds the config' {
        $Script:Config = Get-AppSecConfiguration -ConfigID $NewConfig.configId -EdgeRCFile $EdgeRCFile -Section $Section
        $Config | Should -Not -BeNullOrEmpty
    }

    ### Rename-AppSecConfiguration
    it 'Rename-AppSecConfiguration successfully renames' {
        $Script:RenameResult = Rename-AppSecConfiguration -ConfigID $NewConfig.configId -NewName $TestConfigName -Description $TestConfigDescription -EdgeRCFile $EdgeRCFile -Section $Section
        $RenameResult.Name | Should -Be $TestConfigName
    }

    ### List-AppSecCustomRules
    it 'List-AppSecCustomRules returns something' {
        $Script:CustomRules = List-AppSecCustomRules -ConfigID $NewConfig.configId -EdgeRCFile $EdgeRCFile -Section $Section
        $CustomRules | Should -Not -BeNullOrEmpty
    }

    ### Get-AppSecCustomRule
    it 'Get-AppSecCustomRule returns newly created rule' {
        $Script:CustomRule = Get-AppSecCustomRule -ConfigID $NewConfig.configId -RuleID $NewCustomRule.id -EdgeRCFile $EdgeRCFile -Section $Section
        $CustomRule.id | Should -Be $NewCustomRule.id
    }

    ### Set-AppSecCustomRule by pipeline
    it 'Set-AppSecCustomRule completes successfully' {
        { $Script:SetCustomRule = $NewCustomRule | Set-AppSecCustomRule -ConfigID $NewConfig.configId -RuleID $NewCustomRule.id -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    ### Set-AppSecCustomRule by body
    it 'Set-AppSecCustomRule completes successfully' {
        { $Script:SetCustomRule = Set-AppSecCustomRule -ConfigID $NewConfig.configId -RuleID $NewCustomRule.id -Body $TestCustomRule -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    AfterAll {
        ### Remove-AppSecCustomRule
        try{
            $CustomRuleRemoval = Remove-AppSecCustomRule -ConfigID $NewConfig.ConfigId -RuleID $NewCustomRule.id -EdgeRCFile $EdgeRCFile -Section $Section
        }
        catch{
            Write-Host $_
        }

        ### Remove-AppSecConfiguration
        try{
            $ConfigRemoval = Remove-AppSecConfiguration -ConfigID $NewConfig.ConfigId -EdgeRCFile $EdgeRCFile -Section $Section
        }
        catch{
            Write-Host $_
        }
        

        Write-Host "Config ID = $($NewConfig.configId)"
        Write-Host "After all complete"
    }
    
}

Describe 'Unsafe AppSec Tests' {
    BeforeDiscovery {
        Write-Host "Before discovery"
    }

    Write-Host "Hello"

    AfterAll {
        Write-Host "After all"
    }
    
}