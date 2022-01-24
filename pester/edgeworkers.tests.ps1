Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestGroupID = 131831
$Script:TestEdgeworkerName = 'akamaipowershell-testing'
$Script:TestEdgeworkerVersion = '0.0.1'
$Script:BundleJson = '{ "edgeworker-version": "0.0.1", "description" : "Pester testing" }'
$Script:MainJS = 'export function onClientRequest (request) {}'

Describe 'Safe Edgeworker Tests' {

    BeforeAll {
        it 'EW should not already exist' {
            { Get-EdgeWorker -Name $TestEdgeworkerName -EdgeRCFile $EdgeRCFile -Section $Section } | Should -BeNullOrEmpty
        }
    }

    ### List-Edgeworkers
    $Script:EdgeWorkers = List-EdgeWorkers -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-Edgeworkers returns EWs' {
        $EdgeWorkers | Should -Not -BeNullOrEmpty
    }

    ### List-EdgeworkerGroups
    $Script:EdgeWorkerGroups = List-EdgeWorkerGroups -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-EdgeworkerGroups returns groups' {
        $EdgeWorkerGroups | Should -Not -BeNullOrEmpty
    }

    ### List-EdgeWorkerGroupReports
    $Script:Reports = List-EdgeWorkerReports -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-EdgeWorkerGroupReports returns reports' {
        $Reports | Should -Not -BeNullOrEmpty
    }

    ### Get-EdgeworkerGroup
    $Script:Group = Get-EdgeWorkerGroup -GroupID $TestGroupId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-EdgeWorkerGroupReports returns reports' {
        $Group | Should -Not -BeNullOrEmpty
    }

    ### New-EdgeWorker
    $Script:EdgeWorker = New-EdgeWorker -name $TestEdgeworkerName -GroupID $TestGroupID -ResourceTierID 100 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-Edgeworker completes successfully' {
        $EdgeWorker.edgeWorkerId | Should -Not -BeNullOrEmpty
    }

    ### Get-EdgeWorker by name
    $Script:EdgeWorker = Get-EdgeWorker -Name $TestEdgeworkerName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-EdgeWorker by name returns EW' {
        $EdgeWorker.edgeWorkerId | Should -Not -BeNullOrEmpty
    }

    
    ### Get-EdgeWorker by name
    $Script:EdgeWorker = Get-EdgeWorker -EdgeWorkerID $EdgeWorker.edgeWorkerId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-EdgeWorker by ID returns EW' {
        $EdgeWorker.edgeWorkerId | Should -Not -BeNullOrEmpty
    }

    ### Set-EdgeWorker
    $Script:EdgeWorker = Set-EdgeWorker -Name $TestEdgeWorkerName -NewName $TestEdgeWorkerName -GroupID $TestGroupId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-EdgeWorker returns EW' {
        $EdgeWorker.name | Should -Be $TestEdgeWorkerName
    }

    ### New-EdgeWorkerVersion with directory
    New-Item -ItemType Directory -Name $TestEdgeworkerName
    $BundleJson | Set-Content -Path "$TestEdgeworkerName/bundle.json"
    $MainJS | Set-Content -Path "$TestEdgeworkerName/main.js"
    $Script:NewVersion = New-EdgeWorkerVersion -Name $TestEdgeworkerName -CodeDirectory $TestEdgeworkerName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-EdgeWorkerVersion creates a new version and removes it successfully' {
        $NewVersion.edgeWorkerId | Should -Be $EdgeWorker.edgeWorkerId
    }

    ### Remove-EdgeWorkerVersion
    it 'Remove-EdgeWorkerVersion completes successfully' {
        { Remove-EdgeWorkerVersion -Name $TestEdgeworkerName -Version $TestEdgeworkerVersion -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    <#
    ### New-EdgeWorkerVersion with codebundle
    $Script:NewVersion = New-EdgeWorkerVersion -Name $TestEdgeworkerName -CodeBundle "$TestEdgeworkerName\$TestEdgeWorkerName-$TestEdgeWorkerVersion.tgz" -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-EdgeWorkerVersion completes successfully' {
        $NewVersion.edgeWorkerId | Should -Be $EdgeWorker.edgeWorkerId
    }
    #>

    ### Get-EdgeWorkerVersion
    $Script:Version = Get-EdgeWorkerVersion -Name $TestEdgeworkerName -Version $TestEdgeWorkerVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-EdgeWorkerVersion returns the version' {
        $Version.edgeWorkerId | Should -Be $EdgeWorker.edgeWorkerId
    }

    ### List-EdgeWorkerVersions
    $Script:Version = List-EdgeWorkerVersions -Name $TestEdgeworkerName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-EdgeWorkerVersions returns at least 1 version' {
        $Version.edgeWorkerId | Should -Not -BeNullOrEmpty
    }

    ### Remove-EdgeWorker
    it 'Remove-EdgeWorker completes successfully' {
        { Remove-EdgeWorker -EdgeWorkerID $EdgeWorker.edgeWorkerId -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    AfterAll {
        Remove-Item -Recurse $TestEdgeworkerName
    }
    
}

Describe 'Unsafe Edgeworker Tests' {

    
}