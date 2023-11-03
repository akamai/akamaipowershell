function Move-APIKeys
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Keys,
        [Parameter(Mandatory=$true)]  [string] $CollectionID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/apikey-manager-api/v1/keys/move"
    $BodyObj = @{
        keys = ($Keys -split ',')
        collectionId = $CollectionID
    }
    $Body = ConvertTo-Json $BodyObj

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_ 
    }
}
