<#
.SYNOPSIS
Switches the Akamai session information the the passed in session. Use with New-AkamaiSession to initially create the session hashtable.
.PARAMETER AkamaiSession
A session variable created with New-AkamaiSession. Use Get-AkamaiSession to fetch the session information in the correct format.
#>
function Set-AkamaiSession {
    param (
        [Parameter(Mandatory=$true, ParameterSetName="full", Position=1)] [PSCustomObject] $AkamaiSession
    )
        $Script:AkamaiSession = $AkamaiSession
}