function Get-IPGeoLocation
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $IPAddress,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/diagnostic-tools/v2/ip-addresses/$IPAddress/geo-location?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.geolocation
    }
    catch {
        throw $_.Exception
    }
}