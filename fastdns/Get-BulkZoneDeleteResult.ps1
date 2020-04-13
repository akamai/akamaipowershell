function Get-BulkZoneDeleteResult
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]  [string] $RequestID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/config-dns/v2/zones/delete-requests/$($RequestID)/result?accountSwitchKey=$AccountSwitchKey"

    try {
        Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
    }
    catch { throw }

    <#
    .SYNOPSIS
        Retrieves the result from a completed zone delete request.

    .DESCRIPTION
        A zone delete request using Submit-ZoneDeleteRequest is an asynchronous operation that returns a request ID value to track the status/results of the request. This function takes that ID and returns the associated results.
    
    .PARAMETER RequestID
        The request ID returned from a zone delete request.

    .PARAMETER EdgeRCFile
        Path to a valid .edgerc file with authentication information.
    
    .PARAMETER Section
        The section within the .edgerc file to use for authentication.

    .PARAMETER AccountSwitchKey
        This is a feature only used by Partners and Akamai internal users.

    .EXAMPLE
        Get-BulkZoneDeleteResult -RequestID xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

        Get the result of the specified delete request.

    .LINK
        Submit-BulkZoneDeleteRequest
    #>
}