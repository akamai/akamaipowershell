function Get-EdgeHostnameLocalizationData
{
    Param(
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('de_DE','en_US','es_ES','es_LA','fr_FR','it_IT','ja_JP','ko_KR','pt_BR','zh_CN','zh_TW')] $Language,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/hapi/v1/i18n/$Language"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -Body $Body
        return $Result.hapi
    }
    catch {
        throw $_
    }
}
