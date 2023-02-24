function List-ReportTypeVersions
{
    Param(
        [Parameter(Mandatory=$true)] [String] $ReportType,
        [Parameter(Mandatory=$false)] [switch] $ShowDeprecated,
        [Parameter(Mandatory=$false)] [switch] $ShowUnavailable,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Nullify false switches
    $ShowDeprecatedString = $ShowDeprecated.IsPresent.ToString().ToLower()
    if(!$ShowDeprecated){ $ShowDeprecatedString = '' }
    $ShowUnavailableString = $ShowUnavailable.IsPresent.ToString().ToLower()
    if(!$ShowUnavailable){ $ShowUnavailableString = '' }

    $Path = "/reporting-api/v1/reports/$ReportType/versions?showDeprecated=$ShowDeprecatedString&showUnavailable=$ShowUnavailableString"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
