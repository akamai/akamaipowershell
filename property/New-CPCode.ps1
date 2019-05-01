function New-CPCode
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $CPCodeName,
        [Parameter(Mandatory=$true)]  [string] $ProductID,
        [Parameter(Mandatory=$true)]  [string] $ContractID,
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -EdgeRCFile $EdgeRCFile -Section $Section
    if(!$Credentials){ return $null }

    $PostObj = @{"productId" = $ProductID; "cpcodeName" = $CPCodeName}
    $Body = $PostObj | ConvertTo-Json -Dept 10

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/cpcodes?contractId=$ContractID&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"

    $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $Body
    return $Result
}