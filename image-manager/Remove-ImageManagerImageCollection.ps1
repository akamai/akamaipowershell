function Remove-ImageManagerImageCollection {
    Param(
        [Parameter(Mandatory = $true)]  [string] $PolicySetAPIKey,
        [Parameter(Mandatory = $true)]  [string] $ImageCollectionID,
        [Parameter(Mandatory = $false)] [string] $ContractID,
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey
    )

    $Path = "/imaging/v2/imagecollections/$ImageCollectionID"
    $AdditionalHeaders = @{ 'Luna-Token' = $PolicySetAPIKey }

    if ($ContractID -ne '') {
        $AdditionalHeaders['Contract'] = $ContractID
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method DELETE -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
