function List-CloudletPolicies
{
    Param(
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [switch] $IncludeDeleted,
        [Parameter(Mandatory=$false)] [string] $CloudletID,
        [Parameter(Mandatory=$false)] [int]    $Offset,
        [Parameter(Mandatory=$false)] [int]    $Pagesize = 10,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Nullify false switches
    $IncludeDeletedString = $IncludeDeleted.IsPresent.ToString().ToLower()
    if(!$IncludeDeleted){ $IncludeDeletedString = '' }

    $Path = "/cloudlets/api/v2/policies?gid=$GroupID&includedeleted=$IncludeDeletedString&cloudletId=$CloudletId&clonepolicyid=$ClonePolicyID&version=$Version&offset=$Offset&pageSize=$PageSize&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}