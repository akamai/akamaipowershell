function List-NetworkLists
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $Extended,
        [Parameter(Mandatory=$false)] [switch] $IncludeElements,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('IP','GEO')] $ListType,
        [Parameter(Mandatory=$false)] [string] $Search,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Nullify false switches
    $ExtendedString = $Extended.IsPresent.ToString().ToLower()
    if(!$Extended){ $ExtendedString = '' }
    $IncludeElementsString = $IncludeElements.IsPresent.ToString().ToLower()
    if(!$IncludeElements){ $IncludeElementsString = '' }

    $Path = "/network-list/v2/network-lists?extended=$ExtendedString&includeElements=$IncludeElementsString&listType=$ListType&search=$Search"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.networkLists
    }
    catch {
        throw $_
    }
}
