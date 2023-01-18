function Get-ImageManagerImage
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicySetAPIKey,
        [Parameter(Mandatory=$true)]  [string] $ImageID,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('Staging', 'Production')] $Network,
        [Parameter(Mandatory=$false)] [string] $ContractID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Network = $Network.ToLower()
    $Path = "/imaging/v0/network/$Network/images/$ImageID`?accountSwitchKey=$AccountSwitchKey"
    $AdditionalHeaders = @{ 'Luna-Token' = $PolicySetAPIKey }

    if($ContractID -ne ''){
        $AdditionalHeaders['Contract'] = $ContractID
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
