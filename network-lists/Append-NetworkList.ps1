function Append-NetworkList
{
    Param(
        [Parameter(Mandatory=$true)] [string] $NetworkListID,
        [Parameter(Mandatory=$true)] [string] $Elements,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/network-list/v2/network-lists/$NetworkListID/append?accountSwitchKey=$AccountSwitchKey"

    $ElementsArray = $Elements.Replace(" ","").Split(",")
    $Body = @{ list = $ElementsArray } | ConvertTo-Json -Depth 100

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Body $Body -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
