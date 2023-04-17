function List-FRMCidrBlocks
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EffectiveDateGt,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('add', 'update', 'delete')] $LastAction,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )
    
    $Path = "/firewall-rules-manager/v1/cidr-blocks?effectiveDateGt=$EffectiveDateGt&lastAction=$LastAction"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_  
    }
}
