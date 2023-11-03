function New-MSLKey
{
    Param(
        [Parameter(Mandatory=$false)] [string] [ValidateSet('AKAMAI','THIRD_PARTY')] $Type,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/config-media-live/v2/msl-origin/generate-key?type=$Type"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
              
}
