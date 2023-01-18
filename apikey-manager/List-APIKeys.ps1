function List-APIKeys
{
    Param(
        [Parameter(Mandatory=$false)] [string] $CollectionID,
        [Parameter(Mandatory=$false)] [string] $Filter,
        [Parameter(Mandatory=$false)] [string] $PageNumber,
        [Parameter(Mandatory=$false)] [string] $PageSize,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('All','Active','Revoked','Pending')] $KeyType,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('asc','desc')] $SortDirection,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('id','label','description')] $SortColumn,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/apikey-manager-api/v1/keys?collectionId=$CollectionID&filter=$Filter&pageNumber=$PageNumber&keyType=$KeyType&pageSize=$PageSize&sortDirect=$SortDirection&sortColumn=$SortColumn&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_ 
    }
}
