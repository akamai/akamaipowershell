Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestContract = '1-1NC95D'
$Script:TestIPAddress = '1.2.3.4'
$Script:TestHostname = 'ion.stuartmacleod.net'
$Script:1HourAgo = (Get-Date).AddHours(-1)
$Script:EpochTime = [Math]::Floor([decimal](Get-Date($1HourAgo).ToUniversalTime() -uformat "%s"))
$Script:TestErrorCode = "9.44ae3017.$($EpochTime).38e4d065"
$Script:TestDiagnosticsNote = 'AkamaiPowerShell testing. Please ignore'

Describe 'Safe Edge Diagnostics Tests' {

    BeforeDiscovery {

    }

    ### List-EdgeLocations
    $Script:EdgeLocations = List-EdgeLocations -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-EdgeLocations returns a list' {
        $EdgeLocations.count | Should -Not -Be 0
    }

    ### List-IPAccelerationHostnames
    $Script:IPAHostnames = List-IPAccelerationHostnames -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-IPAccelerationHostnames returns a list' {
        $IPAHostnames.count | Should -Not -Be 0
    }

    ### Find-IPAddress
    $Script:IPLocation = Find-IPAddress -IPAddresses $TestIPAddress -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Find-IPAddress returns the correct data' {
        $IPLocation.geolocation | Should -Not -BeNullOrEmpty
    }

    ### New-EdgeDig
    $Script:Dig = New-EdgeDig -Hostname $TestHostname -QueryType CNAME -EdgeLocation $EdgeLocations[0].id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-EdgeDig returns the correct data' {
        $Dig.result | Should -Not -BeNullOrEmpty
    }

    ### New-EdgeCurl
    $Script:Curl = New-EdgeCurl -URL "https://$TestHostname" -IPVersion IPV4 -EdgeLocation $EdgeLocations[0].id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-EdgeCurl returns the correct data' {
        $Curl.result | Should -Not -BeNullOrEmpty
    }

    ### New-EdgeMTR
    $Script:MTR = New-EdgeMTR -Destination $TestHostname -DestinationType HOST -PacketType TCP -Port 80 -ResolveDNS -Source $EdgeLocations[0].id -SourceType LOCATION -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-EdgeCurl returns the correct data' {
        $MTR.result | Should -Not -BeNullOrEmpty
    }

    ### New-MetadataTrace
    $Script:NewTrace = New-MetadataTrace -URL "https://$TestHostname" -Method GET -EdgeLocation $EdgeLocations[0].id -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-MetadataTrace returns the correct data' {
        $NewTrace.requestId | Should -Not -BeNullOrEmpty
    }

    ### Get-MetadataTrace
    $Script:GetTrace = Get-MetadataTrace -RequestID $NewTrace.requestId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-MetadataTrace returns the correct data' {
        $GetTrace.requestId | Should -Be $NewTrace.requestId
    }

    ### Test-EdgeIP
    $Script:TestIP = Test-EdgeIP -IPAddresses $TestIPAddress -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Test-EdgeIP executes successfully' {
        $TestIP.executionStatus | Should -Be 'SUCCESS'
    }

    ### New-ErrorTranslation
    $Script:NewErrorTranslation = New-ErrorTranslation -ErrorCode $TestErrorCode -EdgeRCFile $EdgeRCFile -Section $Section
    it 'New-ErrorTranslation executes successfully' {
        $NewErrorTranslation.executionStatus | Should -Be 'IN_PROGRESS'
    }

    ### Get-ErrorTranslation
    $Script:GetErrorTranslation = Get-ErrorTranslation -RequestID $NewErrorTranslation.requestId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-ErrorTranslation executes successfully' {
        $GetErrorTranslation.requestId | Should -Be $NewErrorTranslation.requestId
    }

    ### Get-DiagnosticLink
    $Script:DiagLink = Get-DiagnosticLink -URL "https://$TestHostname" -Note $TestDiagnosticsNote  -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-DiagnosticLink executes successfully' {
        $DiagLink.note | Should -Be $TestDiagnosticsNote
    }

    ### List-DiagnosticsGroups
    $Script:DiagGroups = List-DiagnosticsGroups -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-DiagnosticsGroups returns a list' {
        $DiagGroups.count | Should -Not -Be 0
    }

    ### Get-DiagnosticGroupData
    $Script:DiagGroup = Get-DiagnosticGroupData -GroupID $DiagGroups[0].groupId -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-DiagnosticGroupData returns records' {
        $DiagGroup.diagnosticLink | Should -Not -BeNullOrEmpty
    }

    AfterAll {
        
    }
    
}

Describe 'Unsafe Edge Diagnostics Tests' {
    
    ## Get-EdgeErrorStatistics
    $Script:EStats = Get-EdgeErrorStatistics -CPCode 123456 -ErrorType EDGE_ERRORS -Delivery ENHANCED_TLS -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-EdgeErrorStatistics returns the correct data' {
        $EStats.result | Should -Not -BeNullOrEmpty
    }

    ## Get-EdgeLogs
    $Script:Logs = Get-EdgeLogs -EdgeIP 1.2.3.4 -CPCode 123456 -ClientIP 3.4.5.6 -LogType F -EdgeRCFile $SafeEdgeRCFile -Start 2022-12-20 -End 2022-12-21 -Section $Section
    it 'Get-EdgeLogs returns the correct data' {
        $Logs.result | Should -Not -BeNullOrEmpty
    }

}