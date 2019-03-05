function Get-TestExecutionDifference
{
    Param(
        [Parameter(Mandatory=$true)] [string] $TestDefinitionExecutionID,
        [Parameter(Mandatory=$true)] [string] $DifferenceID,
        [Parameter(Mandatory=$false)] [switch] $Raw,
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/test-management/v1/test-definition-executions/$TestDefinitionExecutionID/differences/$DifferenceID"
    if($Raw)
    {
        $ReqURL += "/raw-request-response"
    }
    
    if($AccountSwitchKey)
    {
        $ReqURL += "?accountSwitchKey=$AccountSwitchKey"
    }

    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result
    }
    catch {
        return $_ 
    }
}