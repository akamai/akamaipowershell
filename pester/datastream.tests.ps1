Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestContract = '1-1NC95D'
$Script:TestGroupID = 209759
$Script:TestStreamID = 18893

Describe 'Safe Datastream Tests' {

    BeforeDiscovery {
        
    }

    ### List-DataStreams
    $Script:Streams = List-DataStreams -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-DataStreams returns a list' {
        $Streams.count | Should -Not -BeNullOrEmpty
    }

    ### List-DatastreamConnectors
    $Script:Connectors = List-DatastreamConnectors -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-DatastreamConnectors returns a list' {
        $Connectors.count | Should -Not -BeNullOrEmpty
    }

    ### List-DatastreamDatasetFields
    $Script:Fields = List-DatastreamDatasetFields -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-DatastreamDatasetFields returns a list' {
        $Fields.count | Should -Not -BeNullOrEmpty
    }

    ### List-DatastreamGroups
    $Script:Groups = List-DatastreamGroups -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-DatastreamGroups returns a list' {
        $Groups.count | Should -Not -BeNullOrEmpty
    }

    ### List-DatastreamProducts
    $Script:Products = List-DatastreamProducts -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-DatastreamProducts returns a list' {
        $Products.count | Should -Not -BeNullOrEmpty
    }

    ### List-DataStreamProperties
    $Script:Properties = List-DataStreamProperties -GroupID $TestGroupID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-DataStreamProperties returns a list' {
        $Properties.count | Should -Not -BeNullOrEmpty
    }

    ### Get-DataStream
    $Script:Stream = Get-DataStream -StreamID $TestStreamID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-DataStream returns the correct stream' {
        $Stream.streamId | Should -Be $TestStreamID
    }

    ### Get-DataStreamVersion
    $Script:Version = Get-DataStreamVersion -StreamID $TestStreamID -Version 1 -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-DataStreamVersion returns the correct stream' {
        $Version.streamId | Should -Be $TestStreamID
    }

    ### Get-DataStreamHistory
    $Script:StreamHistory = Get-DataStreamHistory -StreamID $TestStreamID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-DataStreamHistory returns the correct stream' {
        $StreamHistory[0].streamId | Should -Be $TestStreamID
    }

    ### Get-DataStreamActivationHistory
    $Script:ActivationHistory = Get-DataStreamActivationHistory -StreamID $TestStreamID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-DataStreamActivationHistory returns the correct stream' {
        $ActivationHistory[0].streamId | Should -Be $TestStreamID
    }

    AfterAll {
        
    }
    
}

Describe 'Unsafe Datastream Tests' {
    ### New-DataStream
    $Script:NewStream = New-DataStream -Stream $Stream -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'New-DataStream creates successfully' {
        $NewStream.streamStatus | Should -Be "ACTIVATING"
    }

    ### Remove-DataStream
    it 'Remove-DataStream deletes successfully' {
        { Remove-DataStream -StreamID $TestStreamID -EdgeRCFile $SafeEdgeRCFile -Section $Section } | Should -Not -Throw
    }

    ### Set-DataStream by pipeline
    $Script:StreamByPipeline = ( $Stream | Set-DataStream -StreamID $TestStreamID -EdgeRCFile $SafeEdgeRCFile -Section $Section )
    it 'Set-DataStream completes successfully' {
        $StreamByPipeline.streamStatus | Should -Be "ACTIVATING"
    }

    ### Set-DataStream by body
    $Script:StreamByBody = Set-DataStream -StreamID $TestStreamID -Body (ConvertTo-Json -depth 100 $Stream) -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Set-DataStream completes successfully' {
        $StreamByBody.streamStatus | Should -Be "ACTIVATING"
    }
    
    ### Activate-DataStream
    $Script:Activate = Activate-DataStream -StreamID $TestStreamID -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Activate-DataStream activates successfully' {
        $Activate.streamStatus | Should -Be "ACTIVATING"
    }

    ### Deactivate-DataStream
    $Script:Deactivate = Deactivate-DataStream -StreamID $TestStreamID -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Deactivate-DataStream deactivates successfully' {
        $Deactivate.streamStatus | Should -Be "ACTIVATING"
    }
}