Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestGroupID = 209759
$Script:TestNamespace = 'akamaipowershell-testing'
$Script:TestNamespaceObj = [PSCustomObject] @{
    name = $TestNameSpace
    retentionInSeconds = 0
    groupId = $TestGroupID
}
$Script:TestNamespaceBody = $Script:TestNamespaceObj | ConvertTo-Json
$Script:TestTokenName = 'akamaipowershell-testing'
$Script:Tomorrow = (Get-Date).AddDays(1)
$Script:TommorowsDate = Get-Date $Tomorrow -Format yyyy-MM-dd
$Script:NewItemID = 'pester'
$Script:NewItemContent = 'new'

Describe 'Safe EdgeKV Tests' {

    BeforeDiscovery {
        ### New-EdgeKVAccessToken
        $Script:Token = New-EdgeKVAccessToken -Name $TestTokenName -AllowOnStaging -Expiry $TommorowsDate -Namespace $TestNameSpace -Permissions r -EdgeRCFile $EdgeRCFile -Section $Section
        it 'New-EdgeKVAccessToken returns list of tokens' {
            $Token.name | Should -Be $TestTokenName
        }
    }

    ### Get-EdgeKVInitializationStatus
    $Script:Status = Get-EdgeKVInitializationStatus -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-EdgeKVInitializationStatus returns status' {
        $Status.accountStatus | Should -Be "INITIALIZED"
    }

    ### List-EdgeKVNamespaces
    $Script:Namespaces = List-EdgeKVNamespaces -Network STAGING -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-EdgeKVNamespaces returns list of namespaces' {
        $Namespaces.count | Should -Not -Be 0
    }

    ### Get-EdgeKVNamespace
    $Script:Namespace = Get-EdgeKVNamespace -Network STAGING -NamespaceID $TestNamespace -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-EdgeKVNamespace returns namespace' {
        $Namespace.namespace | Should -Be $TestNamespace
    }

    ### Set-EdgeKVNamespace with attributes
    $Script:SetNamespaceByAttr = Set-EdgeKVNamespace -Network STAGING -NamespaceID $TestNamespace -Name $TestNameSpace -RetentionInSeconds 0 -GroupID $TestGroupID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-EdgeKVNamespace returns namespace' {
        $SetNamespaceByAttr.namespace | Should -Be $TestNamespace
    }

    ### Set-EdgeKVNamespace with pipeline
    $Script:SetNamespaceByObj = $TestNamespaceObj | Set-EdgeKVNamespace -Network STAGING -NamespaceID $TestNamespace -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-EdgeKVNamespace returns namespace' {
        $SetNamespaceByObj.namespace | Should -Be $TestNamespace
    }

    ### Set-EdgeKVNamespace with body
    $Script:SetNamespaceByBody = Set-EdgeKVNamespace -Network STAGING -NamespaceID $TestNamespace -Body $TestNamespaceBody -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-EdgeKVNamespace returns namespace' {
        $SetNamespaceByBody.namespace | Should -Be $TestNamespace
    }

    ### List-EdgeKVAccessTokens
    $Script:Tokens = List-EdgeKVAccessTokens -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-EdgeKVAccessTokens returns list of tokens' {
        $Tokens.count | Should -Not -Be 0
    }

    ### Get-EdgeKVAccessToken
    $Script:Token = Get-EdgeKVAccessToken -TokenName $TestTokenName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-EdgeKVAccessToken returns list of tokens' {
        $Token.name | Should -Be $TestTokenName
    }

    ### New-EdgeKVItem
    $Script:NewItem = New-EdgeKVItem -ItemID $NewItemID -Value $NewItemContent -Network STAGING -NamespaceID $TestNameSpace -GroupID $TestGroupID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-EdgeKVItem creates successfully' {
        $NewItem | Should -Match 'Item was upserted in database'
    }

    ### List-EdgeKVItems
    $Script:Items = List-EdgeKVItems -Network STAGING -NamespaceID $TestNameSpace -GroupID $TestGroupID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-EdgeKVItems returns list of items' {
        $Items.count | Should -Not -Be 0
    }

    ### Get-EdgeKVItem
    $Script:Item = Get-EdgeKVItem -ItemID $NewItemID -Network STAGING -NamespaceID $TestNameSpace -GroupID $TestGroupID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-EdgeKVItem returns item data' {
        $Item | Should -Not -BeNullOrEmpty
    }

    ### Remove-EdgeKVAccessToken
    $Script:TokenRemoval = Remove-EdgeKVAccessToken -TokenName $TestTokenName -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Remove-EdgeKVAccessToken removes token successfully' {
        $TokenRemoval.name | Should -Be $TestTokenName
    }

    ### Remove-EdgeKVItem
    $Script:Removal = Remove-EdgeKVItem -ItemID $NewItemID -Network STAGING -NamespaceID $TestNameSpace -GroupID $TestGroupID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Remove-EdgeKVItem creates successfully' {
        $Removal | Should -Match 'Item was marked for deletion from database'
    }

    AfterAll {
        
    }
    
}

Describe 'Unsafe EdgeKV Tests' {
    ### Initialize-EdgeKV
    $Script:Initialize = Initialize-EdgeKV -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Initialize-EdgeKV does not throw' {
        $Initialize.accountStatus | Should -Be "INITIALIZED"
    }

    ### New-EdgeKVNamespace
    $Script:SafeNamespace = New-EdgeKVNamespace -Network PRODUCTION -GeoLocation US -Name $TestNamespace -RetentionInSeconds 0 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'New-EdgeKVNamespace creates successfully' {
        $SafeNamespace.namespace | Should -Be $TestNamespace
    }
    
}
