function Get-ErrorStringTranslation
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ErrorString,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/diagnostic-tools/v2/errors/$ErrorString/translated-error?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.translatedError
    }
    catch {
        throw $_.Exception
    }
}