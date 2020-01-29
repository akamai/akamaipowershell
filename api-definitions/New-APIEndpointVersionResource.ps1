function New-APIEndpointVersionResource
{
    Param(
        [Parameter(Mandatory=$true)]  [int] $APIEndpointID,
        [Parameter(Mandatory=$true)]  [int] $VersionNumber,
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/api-definitions/v2/endpoints/$APIEndpointID/versions/$VersionNumber/resources?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception 
    }
}