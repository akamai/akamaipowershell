function Set-EdgeHostname
{
    Param(
        [Parameter(Mandatory=$true)] [string] $RecordName,
        [Parameter(Mandatory=$true)] [string] $DNSZone,
        [Parameter(Mandatory=$true)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $Comments,
        [Parameter(Mandatory=$false)] [string] $StatusUpdateEmail,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/hapi/v1/dns-zones/$DNSZone/edge-hostnames/$RecordName`?comments=$Comments&statusUpdateEmail=$StatusUpdateEmail&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method PATCH -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
        return $Result
    }
    catch {
        throw $_.Exception
    }
}

