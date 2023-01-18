function List-ChinaCDNHoldingEntities
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/chinacdn/v1/icp-holding-entities?accountSwitchKey=$AccountSwitchKey"

    $AdditionalHeaders = @{
        Accept = 'application/vnd.akamai.chinacdn.icp-holding-entities.v1+json'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.icpHoldingEntities
    }
    catch {
        throw $_ 
    }
}
