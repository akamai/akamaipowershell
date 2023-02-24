function List-MSLOrigins
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EncorderLocation,
        [Parameter(Mandatory=$false)] [string] $CPCode,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/config-media-live/v2/msl-origin/origins?encoderLocation=$EncorderLocation&cpcode=$CPCode"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
              
}
