Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestContract = '1-1NC95D'
$Script:TestGroupID = 131831
$Script:TestCollectionName = "Akamai PowerShell"
$Script:TestCollectionBody = "{
    `"contractId`": `"$TestContract`",
    `"groupId`": $TestGroupID,
    `"name`": `"$TestCollectionName`"
}"
$Script:TestAPIEndpointID = 817948
$Script:TestKey = (New-Guid).Guid
$Script:ImportKeys = '[{"value":"7131e629-41fa-4dfb-9ab9-5e556221b8d5","label":"premium","tags":["external","premium"]}]'
$Script:TestCounterName = 'Akamai PowerShell counter'
$Script:TestCounterBody = "{
    `"enabled`": true,
    `"groupId`": $TestGroupID,
    `"name`": `"$TestCounterName`",
    `"throttling`": 1000,
    `"contractId`": `"$TestContract`",
    `"onOverLimit`": `"DENY`"
}"

Describe 'Safe API Key Manager Tests' {

    BeforeDiscovery {
        
    }

    ### List-APIKeyCollections
    $Script:KeyCollections = List-APIKeyCollections -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-APIKeyCollections returns a list' {
        $KeyCollections.count | Should -Not -BeNullOrEmpty
    }

    ### New-APIKeyCollection
    $Script:NewCollection = New-APIKeyCollection -Body $TestCollectionBody -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-APIKeyCollection creates successfully' {
        $NewCollection.name | Should -Be $TestCollectionName
    }

    ### Get-APIKeyCollection
    $Script:Collection = Get-APIKeyCollection -CollectionID $NewCollection.id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-APIKeyCollection returns the collection collection' {
        $Collection.name | Should -Be $TestCollectionName
    }

    ### Set-APIKeyCollection by pipeline
    $Script:CollectionByPipeline = ( $NewCollection | Set-APIKeyCollection -CollectionID $NewCollection.id -EdgeRCFile $EdgeRCFile -Section $Section )
    it 'Set-APIKeyCollection by pipeline updates successfully' {
        $CollectionByPipeline.name | Should -Be $TestCollectionName
    }

    ### Set-APIKeyCollection by body
    $Script:CollectionByBody = Set-APIKeyCollection -CollectionID $NewCollection.id -Body (ConvertTo-Json -depth 100 $NewCollection) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-APIKeyCollection by body updates successfully' {
        $CollectionByBody.name | Should -Be $TestCollectionName
    }

    ### Set-APIKeyCollectionACL by pipeline
    $Script:ACLByPipeline = Set-APIKeyCollectionACL -CollectionID $NewCollection.id -ACL @("ENDPOINT-$TestAPIEndpointID") -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-APIKeyCollectionACL by pipeline updates successfully' {
        $ACLByPipeline.dirtyACL | Should -Contain "ENDPOINT-$TestAPIEndpointID"
    }

    ### Set-APIKeyCollectionACL by body
    $Script:ACLByBody = Set-APIKeyCollectionACL -CollectionID $NewCollection.id -Body "[`"ENDPOINT-$TestAPIEndpointID`"]" -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-APIKeyCollectionACL by body updates successfully' {
        $ACLByBody.dirtyACL | Should -Contain "ENDPOINT-$TestAPIEndpointID"
    }

    $EnabledQuota = $NewCollection.quota
    $EnabledQuota.enabled = $true
    ### Set-APIKeyCollectionQuota by pipeline
    $Script:QuotaByPipeline = ($EnabledQuota | Set-APIKeyCollectionQuota -CollectionID $NewCollection.id -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-APIKeyCollectionQuota by pipeline updates successfully' {
        $QuotaByPipeline.quota.enabled | Should -Be $true
    }

    ### Set-APIKeyCollectionQuota by body
    $Script:QuotaByBody = Set-APIKeyCollectionQuota -CollectionID $NewCollection.id -Body (ConvertTo-Json -Depth 100 $EnabledQuota) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-APIKeyCollectionQuota by body updates successfully' {
        $QuotaByBody.quota.enabled | Should -Be $true
    }

    ### List-APIKeyCollectionEndpoints
    $Script:Endpoints = List-APIKeyCollectionEndpoints -CollectionID $NewCollection.id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-APIKeyCollectionEndpoints returns a list' {
        $Endpoints.count | Should -Not -Be 0
    }

    ### New-APIKey
    $Script:NewKey = New-APIKey -CollectionID $NewCollection.id -Value $TestKey -Label "Create single" -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-APIKey creates successfully' {
        $NewKey.value | Should -Be $TestKey
    }

    ### Get-APIKey
    $Script:GetKey = Get-APIKey -KeyID $NewKey.id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-APIKey returns the correct key' {
        $GetKey.value | Should -Be $TestKey
    }

    ### Set-APIKey by pipeline
    $Script:SetKeyByPipeline = ($NewKey | Set-APIKey -KeyID $NewKey.id -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-APIKey by pipeline returns the correct key' {
        $SetKeyByPipeline.value | Should -Be $TestKey
    }

    ### Set-APIKey by body
    $Script:SetKeyByBody = Set-APIKey -KeyID $NewKey.id -Body (ConvertTo-Json -Depth 100 $NewKey) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-APIKey by body returns the correct key' {
        $SetKeyByBody.value | Should -Be $TestKey
    }

    ### New-APIKeys
    it 'New-APIKey creates successfully' {
        { New-APIKeys -CollectionID $NewCollection.id -Count 2 -Label "Create multiple" -IncrementLabel -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    ### List-APIKeys
    $Script:Keys = List-APIKeys -CollectionID $NewCollection.id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-APIKeys returns a list of keys' {
        $Keys.items.count | Should -BeGreaterThan 0
    }

    ### Import-APIKey
    it 'Import-APIKey completes successfully' {
        {Import-APIKey -CollectionID $NewCollection.id -Content $ImportKeys -Filename sample.json -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
    }

    ### Reset-APIKeyQuota
    it 'Reset-APIKeyQuota completes successfully' {
        {Reset-APIKeyQuota -Keys $NewKey.id -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
    }

    ### Revoke-APIKey
    it 'Revoke-APIKey completes successfully' {
        {Revoke-APIKey -Keys $NewKey.id -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
    }

    ### Restore-APIKey
    it 'Restore-APIKey completes successfully' {
        {Restore-APIKey -Keys $NewKey.id -EdgeRCFile $EdgeRCFile -Section $Section} | Should -Not -Throw
    }

    ### List-APITags
    $Script:Tags = List-APITags -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-APIKeys returns a list' {
        $Tags.count | Should -Not -BeNullOrEmpty
    }

    ### List-APIThrottlingCounters
    $Script:Counters = List-APIThrottlingCounters -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-APIThrottlingCounters returns a list' {
        $Counters.count | Should -Not -BeNullOrEmpty
    }

    ### New-APIThrottlingCounter
    $Script:NewCounter = New-APIThrottlingCounter -Body $TestCounterBody -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-APIThrottlingCounter creates successfully' {
        $NewCounter.name | Should -Be $TestCounterName
    }

    ### Get-APIThrottlingCounter
    $Script:Counter = Get-APIThrottlingCounter -CounterID $NewCounter.id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-APIThrottlingCounter finds the correct counter' {
        $Counter.name | Should -Be $TestCounterName
    }

    ### Set-APIThrottlingCounter by pipeline
    $Script:CounterByPipeline = ($NewCounter | Set-APIThrottlingCounter -CounterID $NewCounter.id -EdgeRCFile $EdgeRCFile -Section $Section)
    it 'Set-APIThrottlingCounter by pipeline updates correctly' {
        $CounterByPipeline.name | Should -Be $TestCounterName
    }

    ### Set-APIThrottlingCounter by body
    $Script:CounterByBody = Set-APIThrottlingCounter -CounterID $NewCounter.id -Body (ConvertTo-Json -Depth 100 $NewCounter) -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Set-APIThrottlingCounter by body updates correctly' {
        $CounterByBody.name | Should -Be $TestCounterName
    }

    ### List-APIThrottlingCounterEndpoints
    $Script:CounterEndpoints = List-APIThrottlingCounterEndpoints -CounterID $NewCounter.id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-APIThrottlingCounterEndpoints returns a list' {
        $CounterEndpoints.count | Should -Not -BeNullOrEmpty
    }

    ### List-APIThrottlingCounterKeys
    $Script:CounterKeys = List-APIThrottlingCounterKeys -CounterID $NewCounter.id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-APIThrottlingCounterKeys returns a list' {
        $CounterKeys.count | Should -Not -BeNullOrEmpty
    }

    ### Remove-APIThrottlingCounter
    it 'Remove-APIThrottlingCounter removes successfully' {
        { $Script:RemoveCounter = Remove-APIThrottlingCounter -CounterID $NewCounter.id -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    ### Remove-APIKeyCollection
    it 'Remove-APIKeyCollection removes successfully' {
        { $Script:RemoveCollection = Remove-APIKeyCollection -CollectionID $NewCollection.id -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    AfterAll {
        
    }
    
}

Describe 'Unsafe API Key Manager Tests' {
    ### Generate-APIKeyReport
    $Script:Report = Generate-APIKeyReport -ReportType rapidkey-by-time -Version 1 -Start 2022-08-13T00:00:00Z -End 2022-08-14T00:00:00Z -Interval HOUR -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Generate-APIKeyReport returns data' {
        $Report.data | Should -Not -BeNullOrEmpty
    }
    
}