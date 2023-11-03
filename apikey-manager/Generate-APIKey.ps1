function Generate-APIKeys
{
    Param(
        [Parameter(Mandatory=$true)]  [int]    $CollectionID,
        [Parameter(Mandatory=$true)]  [int]    $Count,
        [Parameter(Mandatory=$false)] [string] $Description,
        [Parameter(Mandatory=$false)] [bool]   $IncrementLabel,
        [Parameter(Mandatory=$false)] [string] $Label,
        [Parameter(Mandatory=$false)] [string] $Tags,
        [Parameter(Mandatory=$false)] [string] $TerminationAt,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/apikey-manager-api/v1/keys"
    $BodyObj = @{
        collectionId = $CollectionID
        count = $Count
        value = $Value
    }

    if($Description){
        $BodyObj['description'] = $Description
    }
    if($Label){
        $BodyObj['label'] = $Label
    }
    if($Tags){
        $BodyObj['tags'] = $Tags -split ','
    }
    if($IncrementLabel){
        $BodyObj['incrementLabel'] = $IncrementLabel
    }
    if($TerminationAt){
        $BodyObj['terminationAt'] = $TerminationAt
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_ 
    }
}
