<#
.SYNOPSIS
Switches the Akamai session information the the passed in session. Use with New-AkamaiSession to initially create the session hashtable.
.PARAMETER AkamaiSession
A session variable created with New-AkamaiSession. Use Get-AkamaiSession to fetch the session information in the correct format.
#>
function Set-AkamaiSession {
    param (
        [Parameter(Mandatory=$true, ParameterSetName="full")] [hashtable] $AkamaiSession,
        [Parameter(Mandatory=$true, ParameterSetName="auth")] [hashtable] $AuthProperty
    )

    if([string]::IsNullOrWhiteSpace($AkamaiSession)){
        if(-not $script:AkamaiSession){
            $script:AkamaiSession = @{}
        }
        $script:AkamaiSession.Auth = $AuthProperty
    } else {
        $Script:AkamaiSession = $AkamaiSession
    }
}