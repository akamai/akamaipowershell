function List-ChinaCDNHoldingEntities
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/chinacdn/v1/icp-holding-entities"

    $AdditionalHeaders = @{
        Accept = 'application/vnd.akamai.chinacdn.icp-holding-entities.v1+json'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.icpHoldingEntities
    }
    catch {
        throw $_ 
    }
}
