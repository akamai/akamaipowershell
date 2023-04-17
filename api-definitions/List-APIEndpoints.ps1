function List-APIEndpoints
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Category,
        [Parameter(Mandatory=$false)] [string] $Contains,
        [Parameter(Mandatory=$false)] [string] $ContractID,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [int]    $Page,
        [Parameter(Mandatory=$false)] [int]    $PageSize,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('ONLY_VISIBLE', 'ONLY_HIDDEN', 'ALL')] $Show,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('name', 'updateDate')] $SortBy,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('asc', 'desc')] $SortOrder,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('ACTIVATED_FIRST', 'LAST_UPDATED')] $VersionPreference,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/api-definitions/v2/endpoints?page=$Page&pageSize=$PageSize&category=$Category&contains=$Contains&sortBy=$SortBy&sortOrder=$SortOrder&versionPreference=$VersionPreference&show=$Show&contractId=$ContractID&groupId=$GroupID"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.apiEndpoints
    }
    catch {
        throw $_ 
    }
}
