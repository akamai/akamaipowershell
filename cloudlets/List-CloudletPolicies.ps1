function List-CloudletPolicies
{
    Param(
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [switch] $IncludeDeleted,
        [Parameter(Mandatory=$false)] [string] $CloudletID,
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

    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result
    }
    catch {
        return $_
    }
}