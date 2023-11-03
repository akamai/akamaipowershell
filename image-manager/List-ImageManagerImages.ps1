function List-ImageManagerImages {
    Param(
        [Parameter(Mandatory = $true)]  [string] $PolicySetAPIKey,
        [Parameter(Mandatory = $true)]  [string] [ValidateSet('Staging', 'Production')] $Network,
        [Parameter(Mandatory = $false)] [string] $PolicyID,
        [Parameter(Mandatory = $false)] [string] $URL,
        [Parameter(Mandatory = $false)] [string] $Limit,
        [Parameter(Mandatory = $false)] [string] $ContractID,
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey
    )

    $Path = "/imaging/v2/network/$Network/images?limit=$limit&policyId=$PolicyID&url=$URL"
    $AdditionalHeaders = @{ 'Luna-Token' = $PolicySetAPIKey }

    if ($ContractID -ne '') {
        $AdditionalHeaders['Contract'] = $ContractID
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
