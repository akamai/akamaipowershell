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

    ### Get-AkamaiCredentials from edgerc
    it 'Get-AkamaiCredentials from edgercFile parses correctly' {
        $Script:Auth = Get-AkamaiCredentials -EdgeRCFile $SafeEdgeRCFile -Section $Section
        $Auth.client_token | Should -Not -BeNullOrEmpty
        $Auth.access_token | Should -Not -BeNullOrEmpty
        $Auth.client_secret | Should -Not -BeNullOrEmpty
        $Auth.host | Should -Not -BeNullOrEmpty
    }

    ### Get-AkamaiCredentials from environment, default section
    it 'Get-AkamaiCredentials from default environment parses correctly' {
        $env:AKAMAI_HOST = 'env-host'
        $env:AKAMAI_CLIENT_TOKEN = 'env-client_token'
        $env:AKAMAI_ACCESS_TOKEN = 'env-access_token'
        $env:AKAMAI_CLIENT_SECRET = 'env-client_secret'
        $Script:DefaultEnvAuth = Get-AkamaiCredentials
        $DefaultEnvAuth.client_token | Should -Be 'env-client_token'
        $DefaultEnvAuth.access_token | Should -Be 'env-access_token'
        $DefaultEnvAuth.client_secret | Should -Be 'env-client_secret'
        $DefaultEnvAuth.host | Should -Be 'env-host'
    }

    ### Get-AkamaiCredentials from environment, custom section
    it 'Get-AkamaiCredentials from custom environment parses correctly' {
        $env:AKAMAI_CUSTOM_HOST = 'customenv-host'
        $env:AKAMAI_CUSTOM_CLIENT_TOKEN = 'customenv-client_token'
        $env:AKAMAI_CUSTOM_ACCESS_TOKEN = 'customenv-access_token'
        $env:AKAMAI_CUSTOM_CLIENT_SECRET = 'customenv-client_secret'
        $Script:CustomEnvAuth = Get-AkamaiCredentials -Section Custom
        $CustomEnvAuth.client_token | Should -Be 'customenv-client_token'
        $CustomEnvAuth.access_token | Should -Be 'customenv-access_token'
        $CustomEnvAuth.client_secret | Should -Be 'customenv-client_secret'
        $CustomEnvAuth.host | Should -Be 'customenv-host'
    }

    ### Get-AkamaiCredentials from session
    it 'Get-AkamaiCredentials from session parses correctly' {
        New-AkamaiSession -ClientSecret 'session-client_secret' -HostName 'session-host' -ClientAccessToken 'session-access_token' -ClientToken 'session-client_token'
        $Script:SessionAuth = Get-AkamaiCredentials
        $SessionAuth.client_token | Should -Be 'session-client_token'
        $SessionAuth.access_token | Should -Be 'session-access_token'
        $SessionAuth.client_secret | Should -Be 'session-client_secret'
        $SessionAuth.host | Should -Be 'session-host'
    }

    ### Get-NetstorageCredentials from file
    $Script:NSAuth = Get-NetstorageCredentials -AuthFile $SafeAuthFile -Section $Section
    it 'Get-NetstorageCredentials from file parses correctly' {
        $NSAuth.cpcode | Should -Not -BeNullOrEmpty
        $NSAuth.group | Should -Not -BeNullOrEmpty
        $NSAuth.key | Should -Not -BeNullOrEmpty
        $NSAuth.id | Should -Not -BeNullOrEmpty
        $NSAuth.host | Should -Not -BeNullOrEmpty
    }

    ### Get-NetstorageCredentials from default environment
    it 'Get-NetstorageCredentials from default environment parses correctly' {
        $env:NETSTORAGE_CPCODE = 'env-cpcode'
        $env:NETSTORAGE_GROUP = 'env-group'
        $env:NETSTORAGE_KEY = 'env-key'
        $env:NETSTORAGE_ID = 'env-id'
        $env:NETSTORAGE_HOST = 'env-host'
        $Script:DefaultEnvNSAuth = Get-NetstorageCredentials
        $DefaultEnvNSAuth.cpcode | Should -Be 'env-cpcode'
        $DefaultEnvNSAuth.group | Should -Be 'env-group'
        $DefaultEnvNSAuth.key | Should -Be 'env-key'
        $DefaultEnvNSAuth.id | Should -Be 'env-id'
        $DefaultEnvNSAuth.host | Should -Be 'env-host'
    }

    ### Get-NetstorageCredentials from custom environment
    it 'Get-NetstorageCredentials from custom environment parses correctly' {
        $env:NETSTORAGE_CUSTOM_CPCODE = 'customenv-cpcode'
        $env:NETSTORAGE_CUSTOM_GROUP = 'customenv-group'
        $env:NETSTORAGE_CUSTOM_KEY = 'customenv-key'
        $env:NETSTORAGE_CUSTOM_ID = 'customenv-id'
        $env:NETSTORAGE_CUSTOM_HOST = 'customenv-host'
        $Script:CustomEnvNSAuth = Get-NetstorageCredentials -Section Custom
        $CustomEnvNSAuth.cpcode | Should -Be 'customenv-cpcode'
        $CustomEnvNSAuth.group | Should -Be 'customenv-group'
        $CustomEnvNSAuth.key | Should -Be 'customenv-key'
        $CustomEnvNSAuth.id | Should -Be 'customenv-id'
        $CustomEnvNSAuth.host | Should -Be 'customenv-host'
    }

    ### Remove-AkamaiSession
    it 'Remove-AkamaiSession should not throw an error' {
        { Remove-AkamaiSession } | Should -Not -Throw
    }

    AfterAll {
        ## Clean up env variables
        Remove-Item -Path env:\AKAMAI_HOST
        Remove-Item -Path env:\AKAMAI_CLIENT_TOKEN
        Remove-Item -Path env:\AKAMAI_ACCESS_TOKEN
        Remove-Item -Path env:\AKAMAI_CLIENT_SECRET
        Remove-Item -Path env:\AKAMAI_CUSTOM_HOST
        Remove-Item -Path env:\AKAMAI_CUSTOM_CLIENT_TOKEN
        Remove-Item -Path env:\AKAMAI_CUSTOM_ACCESS_TOKEN
        Remove-Item -Path env:\AKAMAI_CUSTOM_CLIENT_SECRET
        Remove-Item -Path env:\NETSTORAGE_CPCODE
        Remove-Item -Path env:\NETSTORAGE_GROUP
        Remove-Item -Path env:\NETSTORAGE_KEY
        Remove-Item -Path env:\NETSTORAGE_ID
        Remove-Item -Path env:\NETSTORAGE_HOST
    }
    
}

Describe 'Unsafe Shared Tests' {
    
}
