function List-EdgeHostnameChangeRequestsForHostname
{
    Param(
        [Parameter(Mandatory=$true)] [string] $RecordName,
        [Parameter(Mandatory=$true)] [string] $DNSZone,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/hapi/v1/dns-zones/$DNSZone/edge-hostnames/$RecordName/change-requests?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
        return $Result
    }
    catch {
        throw $_
    }
}
