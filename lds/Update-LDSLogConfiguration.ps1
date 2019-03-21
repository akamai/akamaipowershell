function Update-LDSLogConfiguration
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $logConfigurationId,
        [Parameter(Mandatory=$true)]  [string] $NewConfigJSON,
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/lds-api/v3/log-configurations/$logConfigurationId?accountSwitchKey=$AccountSwitchKey"
    
    try {
        $Result = Invoke-AkamaiOPEN -Method PUT -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $NewConfigJSON
        return $Result 
    }
    catch {
        return $_
    }
}