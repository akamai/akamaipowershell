function Get-BulkSearchResults
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $BulkSearchID,
        [Parameter(Mandatory=$false)] [string] $GroupId,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/bulk/rules-search-requests/$BulkSearchID`?contractId=$ContractID&groupId=$GroupID"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
