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
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/apikey-manager-api/v1/keys?accountSwitchKey=$AccountSwitchKey"
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
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_ 
    }
}