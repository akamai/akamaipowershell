function List-ChinaCDNICPNumbers
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/chinacdn/v1/icp-numbers"

    $AdditionalHeaders = @{
        Accept = 'application/vnd.akamai.chinacdn.icp-numbers.v1+json'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.icpNumbers
    }
    catch {
        throw $_ 
    }
}
