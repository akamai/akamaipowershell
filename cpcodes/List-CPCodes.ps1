function List-CPCodes
{
    Param(
        [Parameter(Mandatory=$false)] [string] $ContractID,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ProductID,
        [Parameter(Mandatory=$false)] [string] $Name,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($GroupID)
    { 
        # Remove grp_ prefix from group id
        $GroupID = $GroupID.replace("grp_","")
    }
    
    $Path = "/cprg/v1/cpcodes?contractId=$ContractID&groupId=$GroupID&productId=$ProductID&name=$Name&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.cpcodes
    }
    catch {
        throw $_.Exception
    }
}