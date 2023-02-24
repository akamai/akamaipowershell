Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestContract = '1-1NC95D'
$Script:TestEHN = 'akamaipowershell-testing.edgesuite.net'
$Script:TestSecureEHN = 'akamaipowershell-testing.edgekey.net'
$Script:TestEHNRecordName = 'akamaipowershell-testing'

Describe 'Safe HAPI Tests' {

    BeforeDiscovery {
        
    }

    ### List-EdgeHostnames
    $Script:Edges = List-EdgeHostnames -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-EdgeHostnames returns a list' {
        $Edges.count | Should -Not -Be 0
    }

    ### List-EdgeHostnameProducts
    $Script:Products = List-EdgeHostnameProducts -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-EdgeHostnameProducts returns a list' {
        $Products.count | Should -Not -Be 0
    }

    ### Get-EdgeHostname by name
    $Script:EdgeByName = Get-EdgeHostname -EdgeHostname $TestSecureEHN -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-EdgeHostname by name returns the correct data' {
        $EdgeByName.recordName | Should -Be $TestEHNRecordName
    }

    ### Get-EdgeHostname by ID
    $Script:EdgeByID = Get-EdgeHostname -EdgeHostnameID $EdgeByName.edgeHostnameID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-EdgeHostname by ID returns the correct data' {
        $EdgeByID.recordName | Should -Be $TestEHNRecordName
    }

    ### Get-EdgeHostnameCertificate
    $Script:EdgeCert = Get-EdgeHostnameCertificate -RecordName $TestEHNRecordName -DNSZone edgekey.net $EdgeRCFile -Section $Section
    it 'Get-EdgeHostnameCertificate returns the correct data' {
        $EdgeCert.slotNumber | Should -Be $EdgeByName.slotNumber
    }

    ### Get-EdgeHostnameLocalizationData
    $Script:LocalisationData = Get-EdgeHostnameLocalizationData -Language en_US -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-EdgeHostnameLocalizationData contains problems object' {
        $LocalisationData.problems | Should -Not -BeNullOrEmpty
    }

    ### List-EdgeHostnameChangeRequests
    it 'List-EdgeHostnameChangeRequests does not error' {
        { List-EdgeHostnameChangeRequests -Status PENDING -EdgeRCFile $EdgeRCFile -Section $Section } | Should -Not -Throw
    }

    AfterAll {
        
    }
    
}

Describe 'Unsafe HAPI Tests' {
    ## Set-EdgeHostname
    $Script:UpdatedEdge = Set-EdgeHostname -RecordName $TestEHNRecordName -DNSZone edgekey.net -Path ttl -Value 300 -Comments "Testing" -StatusUpdateEmail 'mail@example.com' -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Set-EdgeHostname returns correct data' {
        $UpdatedEdge.action | Should -Be 'EDIT'
    }

    ## Remove-EdgeHostname
    $Script:RemoveEdge = Remove-EdgeHostname -RecordName $TestEHNRecordName -DNSZone edgekey.net -Comments "Testing" -StatusUpdateEmail 'mail@example.com' -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Remove-EdgeHostname returns correct data' {
        $RemoveEdge.action | Should -Be 'DELETE'
    }
    
}
