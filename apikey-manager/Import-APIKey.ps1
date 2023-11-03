function Import-APIKey
{
    Param(
        [Parameter(Mandatory=$true)]  [int]    $CollectionID,
        [Parameter(Mandatory=$true)]  [string] $Content,
        [Parameter(Mandatory=$true)]  [string] $Filename,
        [Parameter(Mandatory=$false)] [switch] $Size,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/apikey-manager-api/v1/keys/import"
    $BodyObj = @{
        collectionId = $CollectionID
        content = $Content
        name = $Filename
    }

    if($Size){
        $BodyObj['size'] = $Size
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
