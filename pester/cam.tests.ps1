Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:Section = 'default'
$Script:TestContract = '1-1NC95D'
$Script:TestKeyName = 'AkamaiPowershell'
$Script:TestKeyVersion = 1
$Script:TestNewKeyBody = '{
    "credentials": {
         "cloudAccessKeyId": "AKAMAICAMKEYID1EXAMPLE",
         "cloudSecretAccessKey": "cDblrAMtnIAxN/g7dF/bAxLfiANAXAMPLEKEY"
    },
    "networkConfiguration": {
         "securityNetwork": "STANDARD_TLS"
    },
    "accessKeyName": "Sales-s3",
    "contractId": "1-7FALA",
    "groupId": 10725
}'
$Script:TestNewKeyObject = ConvertFrom-Json $TestNewKeyBody

Describe 'Safe Cloud Access Manager Tests' {

    BeforeDiscovery {

    }

    ### List-AccessKeys
    $Script:Keys = List-AccessKeys -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AccessKeys returns a list' {
        $Keys.count | Should -Not -BeNullOrEmpty
    }

    # Find test key
    $Script:KeyUID = ($Keys | where accessKeyName -eq $TestKeyName).accessKeyUid
    if($null -eq $KeyUID){
        throw "Unable to find key $TestKeyName. Bailing out"
    }

    ### Get-AccessKey
    $Script:Key = Get-AccessKey -AccessKeyUID $KeyUID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AccessKey returns the right key' {
        $Key.accessKeyName | Should -Be $TestKeyName
    }

    ### List-AccessKeyVersions
    $Script:Versions = List-AccessKeyVersions -AccessKeyUID $KeyUID -EdgeRCFile $EdgeRCFile -Section $Section
    it 'List-AccessKeyVersions returns a list' {
        $Versions.count | Should -Not -BeNullOrEmpty
    }

    ### Get-AccessKeyVersion
    $Script:Version = Get-AccessKeyVersion -AccessKeyUID $KeyUID -Version $TestKeyVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AccessKeyVersion returns the right version' {
        $Version.version | Should -Be $TestKeyVersion
    }

    ### Get-AccessKeyVersionProperties
    $Script:Properties = Get-AccessKeyVersionProperties -AccessKeyUID $KeyUID -Version $TestKeyVersion -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Get-AccessKeyVersionProperties returns a list' {
        $Properties.count | Should -Not -Be 0
    }

    AfterAll {
        
    }
    
}

Describe 'Unsafe Cloud Access Manager Tests' {
    ### New-AccessKey by Body
    $Script:NewKeyByBody = New-AccessKey -Body $TestNewKeyBody -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'New-AccessKey completes successfully' {
        $NewKeyByBody.requestId | Should -Not -BeNullOrEmpty
    }

    ### New-AccessKey by object
    $Script:NewKeyByObject = New-AccessKey -AccessKey $TestNewKeyObject -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'New-AccessKey completes successfully' {
        $NewKeyByObject.requestId | Should -Not -BeNullOrEmpty
    }

    ### Get-AccessKeyCreateRequest
    $Script:CreateRequest = Get-AccessKeyCreateRequest -RequestID 12345 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Get-AccessKeyCreateRequest completes successfully' {
        $CreateRequest.accessKeyVersion.accessKeyUid | Should -Not -BeNullOrEmpty
    }

    ### New-AccessKeyVersion
    $Script:NewVersion = New-AccessKeyVersion -AccessKeyUID $KeyUID -CloudAccessKeyID 123456789 -CloudSecretAccessKey 123456789 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'New-AccessKeyVersion completes successfully' {
        $NewVersion.requestId | Should -Not -BeNullOrEmpty
    }

    ### Remove-AccessKeyVersion
    $Script:RemoveVersion = Remove-AccessKeyVersion -AccessKeyUID $KeyUID -Version 2 -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Remove-AccessKeyVersion completes successfully' {
        $NewVersion.requestId | Should -Not -BeNullOrEmpty
    }
    
}
