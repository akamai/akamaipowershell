function Get-IVMPolicySet {
    Param(
        [Parameter(Mandatory = $false)] [string] $PolicySetID,
        [Parameter(Mandatory = $false)] [string] $ContractID,
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey
    )

    $Path = "/imaging/v2/policysets/$PolicySetID"

    if ($ContractID -ne '') {
        $AdditionalHeaders['Contract'] = $ContractID
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
