function List-FRMCidrBlocks
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EffectiveDateGt,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('add', 'update', 'delete')] $LastAction,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )
    
    $Path = "/firewall-rules-manager/v1/cidr-blocks?effectiveDateGt=$EffectiveDateGt&lastAction=$LastAction&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_  
    }
}
