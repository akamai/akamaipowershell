function List-DatastreamGroups
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/datastream-config-api/v2/log/groups?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.groups
    }
    catch {
        throw $_
    }
}

Set-Alias -Name List-DS2Groups -Value List-DatastreamGroups