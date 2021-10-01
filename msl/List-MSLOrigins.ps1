function List-MSLOrigins
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EncorderLocation,
        [Parameter(Mandatory=$false)] [string] $CPCode,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/config-media-live/v2/msl-origin/origins?encoderLocation=$EncorderLocation&cpcode=$CPCode&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
              
}