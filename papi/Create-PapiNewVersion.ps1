function Create-PapiNewVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [int]    $ProdVersionNo,
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/papi/v1/properties/$PropertyId/versions/?contractId=$ContractId&groupId=$GroupID"
    $PostObject = @{"createFromVersion"=$ProdVersionNo}
    $Body = $PostObject | Convertto-json
    $NewVersion = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $Body
    write-host "New Version Created"
    return $NewVersion
}

