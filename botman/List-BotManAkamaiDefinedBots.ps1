function List-BotManAkamaiDefinedBots
{
    Param(
        [Parameter(Mandatory=$false)] [string] $CategoryID,
        [Parameter(Mandatory=$false)] [switch] $IsRecategorizable,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $IsRecategorizableString = $IsRecategorizable.IsPresent.ToString().ToLower()
    if(!$IsRecategorizable){ $IsRecategorizableString = '' }

    $Path = "/appsec/v1/akamai-defined-bots?categoryId=$CategoryID&isRecategorizable=$IsRecategorizableString"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.bots
    }
    catch {
        throw $_
    }
}
