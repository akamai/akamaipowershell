<#
.SYNOPSIS
Switches the Akamai session information the the passed in session. Use with New-AkamaiSession to initially create the session hashtable.
.PARAMETER AkamaiSession
A session variable created with New-AkamaiSession. Use Get-AkamaiSession to fetch the session information in the correct format.
#>
function Set-AkamaiSession {
    param (
        [Parameter()] [hashtable] $AkamaiSession
    )

    $Script:AkamaiSession = $AkamaiSession
}