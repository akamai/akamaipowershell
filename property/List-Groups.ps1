function List-Groups
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $Detail,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/groups?accountSwitchKey=$AccountSwitchKey"

    try {
        $groups = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        $returnGroup = $groups.groups.items

        if($Detail)
        {
            $returnGroup = $groups
        }
        
        return $returnGroup 
    }
    catch {
        throw $_.Exception
    }           
}