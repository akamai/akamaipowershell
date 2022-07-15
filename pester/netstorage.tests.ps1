Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestStorageGroupID = 1101059
$Script:TestUploadAccountID = 'akamaipowershell'

Describe 'Safe Netstorage Tests' {

    BeforeDiscovery {

    }

    ### List-NSStorageGroups
    $Script:Groups = List-NSStorageGroups -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-NSStorageGroups returns a list' {
        $Groups.count | Should -Not -BeNullOrEmpty
    }

    ### Get-NSStorageGroup
    $Script:Group = Get-NSStorageGroup -StorageGroupID $TestStorageGroupID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-NSStorageGroup returns a group' {
        $Group | Should -Not -BeNullOrEmpty
    }

    ### List-NSUploadAccounts
    $Script:UploadAccounts = List-NSUploadAccounts -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-NSUploadAccounts returns a list' {
        $UploadAccounts.count | Should -Not -BeNullOrEmpty
    }

    ### Get-NSUploadAccount
    $Script:UploadAccount = Get-NSUploadAccount -UploadAccountID $TestUploadAccountID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-NSUploadAccount returns an account' {
        $UploadAccount | Should -Not -BeNullOrEmpty
    }

    ### List-NSZones
    $Script:Zones = List-NSZones -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-NSZones returns a list' {
        $Zones.count | Should -Not -BeNullOrEmpty
    }

    ### Set-NSStorageGroup by pipeline
    $Script:SetGroupByPipeline = ( $Group | Set-NSStorageGroup -StorageGroupID $TestStorageGroupID -EdgeRCFile $EdgeRCFile -Section $Section )
    it 'Set-NSStorageGroup updates details' {
        $SetGroupByPipeline.storageGroupId | Should -Be $TestStorageGroupID
    }

    ### Set-NSStorageGroup by param
    $Script:SetGroupByParam = Set-NSStorageGroup -StorageGroupID $TestStorageGroupID -StorageGroup $Group -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-NSStorageGroup updates details' {
        $SetGroupByParam.storageGroupId | Should -Be $TestStorageGroupID
    }

    ### Set-NSStorageGroup by json
    $Script:SetGroupByBody = Set-NSStorageGroup -StorageGroupID $TestStorageGroupID -Body (ConvertTo-Json $Group -Depth 10) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-NSStorageGroup updates details' {
        $SetGroupByBody.storageGroupId | Should -Be $TestStorageGroupID
    }

    ### Set-NSUploadAccount by pipeline
    $Script:SetAccountByPipeline = ( $UploadAccount | Set-NSUploadAccount -UploadAccountID $TestUploadAccountID -EdgeRCFile $EdgeRCFile -Section $Section )
    it 'Set-NSUploadAccount updates details' {
        $SetAccountByPipeline.uploadAccountId | Should -Be $TestUploadAccountID
    }

    ### Set-NSUploadAccount by param
    $Script:SetAccountByParam = Set-NSUploadAccount -UploadAccountID $TestUploadAccountID -UploadAccount $UploadAccount -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-NSUploadAccount updates details' {
        $SetAccountByParam.uploadAccountId | Should -Be $TestUploadAccountID
    }

    ### Set-NSUploadAccount by json
    $Script:SetAccountByBody = Set-NSUploadAccount -UploadAccountID $TestUploadAccountID -Body (ConvertTo-Json $UploadAccount -Depth 10) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-NSUploadAccount updates details' {
        $SetAccountByBody.uploadAccountId | Should -Be $TestUploadAccountID
    }

    AfterAll {
        
    }
    
}

Describe 'Unsafe Netstorage Tests' {
    ### New-NSStorageGroup by pipeline
    $Script:NewGroupByPipeline = ($Group | New-NSStorageGroup -EdgeRCFile $SafeEdgeRCFile -Section $Section)
    it 'New-NSStorageGroup creates a group' {
        $NewGroupByPipeline | Should -Not -BeNullOrEmpty
    }

    ### New-NSStorageGroup by param
    $Script:NewGroupByParam = New-NSStorageGroup -StorageGroup $Group -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'New-NSStorageGroup creates a group' {
        $NewGroupByParam | Should -Not -BeNullOrEmpty
    }

    ### New-NSStorageGroup by body
    $Script:NewGroupByBody = New-NSStorageGroup -Body (ConvertTo-Json $Group -Depth 100) -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'New-NSStorageGroup creates a group' {
        $NewGroupByBody | Should -Not -BeNullOrEmpty
    }

    ### New-NSUploadAccount by pipeline
    $Script:NewAccountByPipeline = ( $UploadAccount | New-NSUploadAccount -EdgeRCFile $SafeEdgeRCFile -Section $Section )
    it 'Set-NSUploadAccount updates details' {
        $NewGroupByBody | Should -Not -BeNullOrEmpty
    }

    ### New-NSUploadAccount by param
    $Script:NewAccountByParam = New-NSUploadAccount -UploadAccount $UploadAccount -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Set-NSUploadAccount updates details' {
        $NewGroupByBody | Should -Not -BeNullOrEmpty
    }

    ### New-NSUploadAccount by json
    $Script:NewAccountByBody = New-NSUploadAccount -Body (ConvertTo-Json $UploadAccount -Depth 10) -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Set-NSUploadAccount updates details' {
        $NewGroupByBody | Should -Not -BeNullOrEmpty
    }
}