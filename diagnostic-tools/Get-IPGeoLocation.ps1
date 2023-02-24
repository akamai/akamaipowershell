function Get-IPGeoLocation
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $IPAddress,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/diagnostic-tools/v2/ip-addresses/$IPAddress/geo-location"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.geolocation
    }
    catch {
        throw $_
    }
}
