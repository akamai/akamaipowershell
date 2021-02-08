function Get-ChinaCDNPropertyHostname
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Hostname,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/chinacdn/v1/property-hostnames/$Hostname`?accountSwitchKey=$AccountSwitchKey"

    $AdditionalHeaders = @{
        Accept = 'application/vnd.akamai.chinacdn.property-hostname.v1+json'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception 
    }
}