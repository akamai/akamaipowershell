function List-TSIGKeys
{
    Param(
        [Parameter(Mandatory=$false)] [string] $ContractIDs,
        [Parameter(Mandatory=$false)] [string] $Search,
        [Parameter(Mandatory=$false)] [string] $SortBy,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/config-dns/v2/keys?contractIds=$ContractIDs&search=$Search&sortBy=$SortBy&gid=$GroupID&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}