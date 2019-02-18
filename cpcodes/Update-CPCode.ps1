function Update-CPCode
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey,
        [Parameter(Mandatory=$true)]  [string] $CPCode,
        [Parameter(Mandatory=$true)]  [string] $Body
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    # Test JSON if PS 6 or higher
    if($PSVersionTable.PSVersion.Major -ge 6)
    {
        if(!(Test-JSON $Body))
        {
            return "ERROR: Body is not valid JSON"
        }
    }

    $ReqURL = "https://" + $Credentials.host + "/cprg/v1/cpcodes/$CPCode"
    if($AccountSwitchKey)
    {
        $ReqURL += "?accountSwitchKey=$AccountSwitchKey"
    }

    $Result = Invoke-AkamaiOPEN -Method PUT -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $Body

    return $Result
}

