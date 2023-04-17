function New-APIKey
{
    Param(
        [Parameter(Mandatory=$true)]  [int]    $CollectionID,
        [Parameter(Mandatory=$true)]  [string] $Value,
        [Parameter(Mandatory=$false)] [string] $Description,
        [Parameter(Mandatory=$false)] [switch] $IncrementLabel,
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
        value = $Value
        incrementLabel = $IncrementLabel.IsPresent
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
    if($TerminationAt){
        $BodyObj['terminationAt'] = $TerminationAt
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
