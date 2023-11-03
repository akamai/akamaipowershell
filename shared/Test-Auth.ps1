<#
.SYNOPSIS
EdgeGrid Powershell - Core functions
.DESCRIPTION
Checks EdgeGrid auth credentials against regular expressions
.PARAMETER Auth
Auth object containing credential elements. REQUIRED
.EXAMPLE
Test-Auth -Auth $MyAuth
.LINK
techdocs.akamai.com
#>

function Test-Auth {
    Param(
        [Parameter(Mandatory=$true)] [object] $Auth
    )

    $EdgeRCMatch = '^akab-[a-z0-9]{16}-[a-z0-9]{16}'
    $SecretMatch = '[a-zA-Z0-9\+\/=]{44}'

    if($Auth.host -notmatch $EdgeRCMatch){
        Write-Debug "The 'host' attribute of your credentials appears to be invalid"
    }

    if($Auth.client_token -notmatch $EdgeRCMatch){
        Write-Debug "The 'client_token' attribute of your credentials appears to be invalid"
    }
    if($Auth.access_token -notmatch $EdgeRCMatch){
        Write-Debug "The 'access_token' attribute of your credentials appears to be invalid"
    }

    if($Auth.client_secret -notmatch $SecretMatch){
        Write-Debug "The 'client_secret' attribute of your credentials appears to be invalid"
    }
}
