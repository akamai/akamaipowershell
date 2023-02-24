function Get-EdgeHostnameByDNS
{
    Param(
        [Parameter(Mandatory=$true)] [string] $RecordName,
        [Parameter(Mandatory=$true)] [string] $DNSZone,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    Write-Warning "WARNING: This function is deprecated and will be removed in a future release. Use Get-EdgeHostname with the EdgeHostname parameter going forward"

    $Path = "/hapi/v1/dns-zones/$DNSZone/edge-hostnames/$RecordName"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
