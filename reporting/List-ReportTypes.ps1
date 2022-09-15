function List-ReportTypes
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $ShowDeprecated,
        [Parameter(Mandatory=$false)] [switch] $ShowUnavailable,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Nullify false switches
    $ShowDeprecatedString = $ShowDeprecated.IsPresent.ToString().ToLower()
    if(!$ShowDeprecated){ $ShowDeprecatedString = '' }
    $ShowUnavailableString = $ShowUnavailable.IsPresent.ToString().ToLower()
    if(!$ShowUnavailable){ $ShowUnavailableString = '' }

    $Path = "/reporting-api/v1/reports?showDeprecated=$ShowDeprecatedString&showUnavailable=$ShowUnavailableString&accountSwitchKey=$AccountSwitchKey"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
