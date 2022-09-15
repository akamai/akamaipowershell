function List-RecordSets
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Zone,
        [Parameter(Mandatory=$false)] [string] $Page,
        [Parameter(Mandatory=$false)] [string] $PageSize,
        [Parameter(Mandatory=$false)] [string] $Search,
        [Parameter(Mandatory=$false)] [switch] $ShowAll,
        [Parameter(Mandatory=$false)] [string] $SortBy,
        [Parameter(Mandatory=$false)] [string] $Types,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $ShowAllString = $ShowAll.IsPresent.ToString().ToLower()
    if(!$ShowAll){ $ShowAllString = '' }

    $Path = "/config-dns/v2/zones/$Zone/recordsets?page=$Page&pageSize=$PageSize&search=$Search&showAll=$ShowAllString&sortBy=$SortBy&types=$Types&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.recordSets
    }
    catch {
        throw $_
    }
}
