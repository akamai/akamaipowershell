function List-APIEndpointVersions
{
    Param(
        [Parameter(Mandatory=$true)]  [int] $APIEndpointID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/api-definitions/v2/endpoints/$APIEndpointID/versions?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.apiVersions
    }
    catch {
        throw $_.Exception 
    }
}