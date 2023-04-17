function Get-ZoneRecordSets
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Zone,
        [Parameter(Mandatory=$false)] [string] $Page,
        [Parameter(Mandatory=$false)] [string] $PageSize,
        [Parameter(Mandatory=$false)] [string] $Search,
        [Parameter(Mandatory=$false)] [switch] $ShowAll,
        [Parameter(Mandatory=$false)] [string] $SortBy,
        [Parameter(Mandatory=$false)] [string] $Types,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    Write-Host -ForegroundColor Yellow "Warning: This function has been deprecated and will be removed in a future release. Use List-RecordSets"

    $Path = "/config-dns/v2/zones/$Zone/recordsets?page=$Page&pageSize=$PageSize&search=$Search&showAll=$ShowAllString&sortBy=$SortBy&types=$Types"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
