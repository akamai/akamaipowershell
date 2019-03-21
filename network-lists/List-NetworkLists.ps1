function List-NetworkLists
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $Extended,
        [Parameter(Mandatory=$false)] [switch] $IncludeElements,
        [Parameter(Mandatory=$false)] [string] $ListType = "IP",
        [Parameter(Mandatory=$false)] [string] $Search,
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/network-list/v2/network-lists?extended=$Extended&includeElements=$IncludeElements&listType=$ListType&search=$Search&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result
    }
    catch {
        return $_
    }
}

