Import-Module $PSScriptRoot\..\AkamaiPowershell.psm1 -DisableNameChecking -Force
# Setup shared variables
$Script:EdgeRCFile = $env:PesterEdgeRCFile
$Script:SafeEdgeRCFile = $env:PesterSafeEdgeRCFile
$Script:SafeAuthFile = $env:PesterSafeAuthFile
$Script:Section = 'default'
$Script:ClearTextString = 'This is my test string!'
$Script:Base64EncodedString = 'VGhpcyBpcyBteSB0ZXN0IHN0cmluZyE='
$Script:URLEncodedString = 'This%20is%20my%20test%20string!'
$Script:UnsanitisedQuery = 'one=1&two=&three=3&four='
$Script:SanitisedQuery = 'one=1&three=3'
$Script:UnsanitisedFileName = 'This\looks!Kinda<"bad">.txt'
$Script:SanitisedFileName = 'This%5Clooks!Kinda%3C%22bad%22%3E.txt'

Describe 'Safe Shared Tests' {

    BeforeDiscovery {
        
    }

    ### Decode-Base64String
    $Script:Bas64Decode = Decode-Base64String -EncodedString $Base64EncodedString
    it 'Decode-Base64String decodes successfully' {
        $Bas64Decode | Should -Be $ClearTextString
    }

    ### Decode-URL
    $Script:URLDecode = Decode-URL -EncodedString $URLEncodedString
    it 'Decode-URL decodes successfully' {
        $URLDecode | Should -Be $ClearTextString
    }

    ### Get-RandomString - Alphabetical
    $Script:RandomAlphabetical = Get-RandomString -Length 16 -Alphabetical
    it 'Get-RandomString produces alphabetical string' {
        $RandomAlphabetical | Should -Match "[a-z]{16}"
    }

    ### Get-RandomString - AlphaNumeric
    $Script:RandomAlphaNumeric = Get-RandomString -Length 16 -AlphaNumeric
    it 'Get-RandomString produces alphanumeric string' {
        $RandomAlphaNumeric | Should -Match "[a-z0-9]{16}"
    }

    ### Get-RandomString - Numeric
    $Script:RandomNumeric = Get-RandomString -Length 16 -Numeric
    it 'Get-RandomString produces numeric string' {
        $RandomNumeric | Should -Match "[0-9]{16}"
    }

    ### Get-RandomString - Hex
    $Script:RandomHex = Get-RandomString -Length 16 -Hex
    it 'Get-RandomString produces hex string' {
        $RandomHex | Should -Match "[a-f0-9]{16}"
    }

    ### Parse-EdgercFile
    $Script:ParsedEdgeRc = Parse-EdgeRCFile -EdgeRCFile $SafeEdgeRCFile -Section $Section
    it 'Parse-EdgeRcFile parses correctly' {
        $ParsedEdgeRc.$Section.clientToken | Should -Not -BeNullOrEmpty
        $ParsedEdgeRc.$Section.clientAccessToken | Should -Not -BeNullOrEmpty
        $ParsedEdgeRc.$Section.clientSecret | Should -Not -BeNullOrEmpty
        $ParsedEdgeRc.$Section.Host | Should -Not -BeNullOrEmpty
    }

    ### Parse-NSAuthFile
    $Script:ParsedAuth = Parse-NSAuthFile -AuthFile $SafeAuthFile -Section $Section
    it 'Parse-NSAuthFile parses correctly' {
        $ParsedAuth.$Section.cpcode | Should -Not -BeNullOrEmpty
        $ParsedAuth.$Section.group | Should -Not -BeNullOrEmpty
        $ParsedAuth.$Section.key | Should -Not -BeNullOrEmpty
        $ParsedAuth.$Section.id | Should -Not -BeNullOrEmpty
        $ParsedAuth.$Section.host | Should -Not -BeNullOrEmpty
    }

    ### Sanitise-QueryString
    $Script:ParsedQuery = Sanitise-QueryString -QueryString $Script:UnsanitisedQuery
    it 'Sanitise-QueryString strips empty query params' {
        $ParsedQuery | Should -Be $SanitisedQuery
    }

    ### Sanitise-Filename
    $Script:ParsedFileName = Sanitise-FileName -Filename $Script:UnsanitisedFileName
    it 'Sanitise-Filename encodes invalid characters' {
        $ParsedFileName | Should -Be $SanitisedFilename
    }

    ### Test-OpenAPI
    $Script:APIResult = Test-OpenAPI -Path '/papi/v1/contracts' -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Test-OpenAPI returns data successfully' {
        $APIResult.count | Should -Not -Be 0
    }

    ### Verify-Auth
    $Script:Auth = Verify-Auth -ReturnObject -EdgeRCFile $EdgeRCFile -Section $Section
    it 'Verify-Auth returns an object' {
        $Auth.scope | Should -Not -BeNullOrEmpty
    }

    AfterAll {

    }
    
}

Describe 'Unsafe Shared Tests' {
    # ### Get-CPSDVHistory
    # $Script:DVHistory = Get-CPSDVHistory -EnrollmentID $TestEnrollmentID -EdgeRCFile $SafeEdgeRCFile -Section $Section
    # it 'Get-CPSDVHistory returns history' {
    #     $DVHistory.count | Should -BeGreaterThan 0
    # }
    
}
