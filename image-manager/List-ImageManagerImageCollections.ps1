function List-ImageManagerImageCollections {
    Param(
        [Parameter(Mandatory = $true)]  [string] $PolicySetAPIKey,
        [Parameter(Mandatory = $false)] [string] $Limit,
        [Parameter(Mandatory = $false)] [string] $ContractID,
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey
    )

    $Path = "/imaging/v2/imagecollections?limit=$limit"
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
