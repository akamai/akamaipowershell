function Get-ErrorStringTranslation
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ErrorString,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/diagnostic-tools/v2/errors/$ErrorString/translated-error"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.translatedError
    }
    catch {
        throw $_
    }
}
