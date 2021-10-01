function List-MSLStreams
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Page,
        [Parameter(Mandatory=$false)] [string] $PageSize,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('cpcode', 'createdDate', 'dvrWindowInMin', 'format', 'modifiedDate', 'name', 'originHostName', 'status','zone')] $SortKey,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('ASC','DESC')] $SortOrder,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/config-media-live/v2/msl-origin/streams?page=$Page&pageSize=$PageSize&sortKey=$SortKey&sortOrder=$SortOrder&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.streams
    }
    catch {
        throw $_.Exception
    }
              
}