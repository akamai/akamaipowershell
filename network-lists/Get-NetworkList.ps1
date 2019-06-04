function Get-NetworkList
{
    Param(
        [Parameter(Mandatory=$true)] [string] $NetworkListID,
        [Parameter(Mandatory=$false)] [switch] $Extended,
        [Parameter(Mandatory=$false)] [switch] $IncludeElements,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Nullify false switches
    $ExtendedString = $Extended.IsPresent.ToString().ToLower()
    if(!$Extended){ $ExtendedString = '' }
    $IncludeElementsString = $IncludeElements.IsPresent.ToString().ToLower()
    if(!$IncludeElements){ $IncludeElementsString = '' }

    $Path = "/network-list/v2/network-lists/$NetworkListID`?extended=$ExtendedString&includeElements=$IncludeElementsString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}

