function List-CloudletPolicies
{
    Param(
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [switch] $IncludeDeleted,
        [Parameter(Mandatory=$false)] [string] $CloudletID,
        [Parameter(Mandatory=$false)] [string] $ClonePolicyID,
        [Parameter(Mandatory=$false)] [string] $Version,
        [Parameter(Mandatory=$false)] [int]    $Offset,
        [Parameter(Mandatory=$false)] [int]    $Pagesize,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cloudlets/api/v2/policies?&gid=$GroupID&includedeleted=$IncludeDeleted&cloudletId=$CloudletId&clonepolicyid=$ClonePolicyID&version=$Version&accountSwitchKey=$AccountSwitchKey"

    if($Offset){ $ReqURL += "&offset=$Offset"}
    if($Pagesize){ $ReqURL += "&pageSize=$PageSize"}

    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result
    }
    catch {
        throw $_.Exception
    }
}