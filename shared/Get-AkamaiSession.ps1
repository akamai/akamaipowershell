<#
.SYNOPSIS
Gets the current Akamai session information. Used with Set-AkamaiSession to switch session information on the fly.
#>
function Get-AkamaiSession {
    return $Script:AkamaiSession
}
