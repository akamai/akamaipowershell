function List-SharedCloudletPolicies
{
    Param(
        [Parameter(Mandatory=$false)] [int]    $Size = 1000,
        [Parameter(Mandatory=$false)] [string] $Page,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cloudlets/v3/policies?size=$Size&page=$Page"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -ResponseHeadersVariable ResponseHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.content
    }
    catch {
        throw $_
    }
}
