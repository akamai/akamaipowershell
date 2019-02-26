function Get-LDSLogConfiguration
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $logConfigurationId,
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/lds-api/v3/log-configurations/$logConfigurationId"
    
    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result
    }
    catch {
        return $_ 
    }
}