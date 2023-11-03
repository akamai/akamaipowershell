function Get-ChinaCDNDeprovisionPolicy
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $EdgeHostname,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/chinacdn/v1/edge-hostnames/$EdgeHostname/deprovision-policy"

    $AdditionalHeaders = @{
        Accept = 'application/vnd.akamai.chinacdn.deprovision-policy.v1+json'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_ 
    }
}
