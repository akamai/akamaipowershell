function List-LDSLogConfigurationsForID
{
    Param(
        [Parameter(Mandatory=$false)] [string] $logSourceType = "cpcode-products",
        [Parameter(Mandatory=$true)]  [string] $logSourceId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/lds-api/v3/log-sources/$logSourceType/$logSourceId/log-configurations?accountSwitchKey=$AccountSwitchKey"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result 
    }
    catch {
        throw $_.Exception
    }
}