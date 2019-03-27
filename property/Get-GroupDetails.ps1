function Get-GroupDetails
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Group,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/groups?accountSwitchKey=$AccountSwitchKey"
    
    
    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result.groups.items | where {$_.groupName -eq $group} 
    }
    catch {
        throw $_.Exception
    }
}