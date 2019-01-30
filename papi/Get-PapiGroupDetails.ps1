function Get-PapiGroupDetails
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Group,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/groups"
    $groups = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    $returnGroup = $groups.groups.items | where {$_.groupName -eq $group} 
    return $returnGroup          
}

