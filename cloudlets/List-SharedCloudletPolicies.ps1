function List-SharedCloudletPolicies
{
    Param(
        [Parameter(Mandatory=$false)] [int]    $Size = 1000,
        [Parameter(Mandatory=$false)] [string] $Page,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cloudlets/v3/policies?size=$Size&page=$Page&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -ResponseHeadersVariable ResponseHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.content
    }
    catch {
        throw $_
    }
}