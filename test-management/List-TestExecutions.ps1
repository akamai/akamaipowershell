function List-TestExecutions
{
    Param(
        [Parameter(Mandatory=$false)] [string] $TestDefinitionIDs,
        [Parameter(Mandatory=$false)] [switch] $LatestPerTestDefinition,
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/test-management/v1/test-definition-executions?latestPerTestDefinition=$LatestPerTestDefinition&testDefinitionIds=$TestDefinitionIDs"
    if($AccountSwitchKey)
    {
        $ReqURL += "&accountSwitchKey=$AccountSwitchKey"
    }

    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result
    }
    catch {
        return $_ 
    }
}