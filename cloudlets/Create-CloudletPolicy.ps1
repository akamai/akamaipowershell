function Create-CloudletPolicy
{
    Param(
        [Parameter(Mandatory=$true) ] [string] $Name,
        [Parameter(Mandatory=$false)] [string] $Description,
        [Parameter(Mandatory=$true) ] [int]    $GroupID,
        [Parameter(Mandatory=$false)] [switch] $IncludeDeleted,
        [Parameter(Mandatory=$true) ] [int]    $CloudletID,
        [Parameter(Mandatory=$false)] [string] $ClonePolicyID,
        [Parameter(Mandatory=$false)] [string] $Version,
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/policies"

    if($psboundparameters.Count -gt 1) { $ReqURL += "?" }
    if($GroupID)                       { $ReqURL += "&gid=$GroupID" }
    if($IncludeDeleted)                { $ReqURL += "&includedeleted=true" }
    if($CloudletID)                    { $ReqURL += "&dc=$DC" }
    if($ClonePolicyID)                 { $ReqURL += "&clonepolicyid=$ClonePolicyID" }
    if($Version)                       { $ReqURL += "&version=$Version" }


    $Post = @{ name = $Name; cloudletId = $CloudletID; groupId = $GroupID; description = $Description }
    $PostJson = ConvertTo-Json $Post -Depth 10

    $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $PostJson
    return $Result
}

