Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestGroupID = 131831
$Script:TestContract = '1-1NC95D'
$Script:TestListName = 'akamaipowershell-testing'
$Script:TestElement = '1.1.1.1'
$Script:NewTestElements = '2.2.2.2, 3.3.3.3'

Describe 'Safe Network Lists Tests' {

    BeforeDiscovery {
        ### New-NetworkList
        $Script:NewList = New-NetworkList -Name $TestListName -Type IP -Description "testing" -ContractId $TestContract -GroupID $TestGroup -EdgeRCFile $EdgeRCFile -Section $Section
        it 'List-NetworkLists returns a list of lists' {
            $NewList.name | Should -Be $TestListName
        }

        ### AddTo-NetworkList
        $Script:Add = AddTo-NetworkList -NetworkListID $NewList.uniqueId -Element $TestElement -EdgeRCFile $EdgeRCFile -Section $Section
        it 'AddTo-NetworkList adds element' {
            $Add.list | Should -Contain $TestElement
        }
    }

    ### List-NetworkLists
    $Script:NetworkLists = List-NetworkLists -Extended -IncludeElements -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-NetworkLists returns a list of lists' {
        $NetworkLists.count | Should -BeGreaterThan 0
    }

    ### Get-NetworkList
    $Script:List = Get-NetworkList -NetworkListID $NewList.uniqueId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-NetworkList returns specific list' {
        $List.name | Should -Be $TestListName
    }

    ### Set-NetworkList by pipeline
    $Script:SetListByPipeline = $Script:List | Set-NetworkList -NetworkListID $NewList.uniqueId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-NetworkList returns successfully' {
        $SetListByPipeline.name | Should -Be $TestListName
    }

    ### Set-NetworkList by body
    $Script:SetListBody = $Script:List | ConvertTo-Json -Depth 100
    $Script:SetListByBody = Set-NetworkList -NetworkListID $NewList.uniqueId -Body $SetListBody -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-NetworkList returns successfully' {
        $SetListByBody.name | Should -Be $TestListName
    }

    ### Append-NetworkList
    $Script:Append = Append-NetworkList -NetworkListID $NewList.uniqueId -Elements $NewTestElements -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Append-NetworkList adds elements to the correct count' {
        $Append.list.count | Should -Be 3
    }

    AfterAll {
        ### RemoveFrom-NetworkList
        $Script:Remove = RemoveFrom-NetworkList -NetworkListID $NewList.uniqueId -Element $TestElement -EdgeRCFile $EdgeRCFile -Section $Section
        it 'RemoveFrom-NetworkList removes element' {
            $Remove.list | Should -Not -Contain $TestElement
        }

        ### Remove-NetworkList
        $Script:Removal = Remove-NetworkList -NetworkListID $NewList.uniqueId -EdgeRCFile $EdgeRCFile -Section $Section
        it 'Remove-NetworkList removes given list' {
            $Removal.status | Should -Be 200
        }
    }
    
}

Describe 'Unsafe Network Lists Tests' {
    ### Activate-NetworkList
    $Script:Activate = Activate-NetworkList -NetworkListID $NewList.uniqueId -Environment STAGING -Comments "Activating" -NotificationRecipients 'email@example.com' -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Activate-NetworkList activates correctly' {
        $Activate.activationStatus | Should -Not -BeNullOrEmpty
    }

    ### Get-NetworkListActivationStatus
    $Script:Status = Get-NetworkListActivationStatus -NetworkListID $NewList.uniqueId -Environment STAGING -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-NetworkListActivationStatus returns status' {
        $Status.activationStatus | Should -Not -BeNullOrEmpty
    }
}