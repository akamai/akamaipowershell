function List-CPCodes
{
    Param(
        [Parameter(Mandatory=$false)] [string] $ContractID,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ProductID,
        [Parameter(Mandatory=$false)] [string] $Name,
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    if($GroupID)
    { 
        # Remove grp_ prefix from group id
        $GroupID = $GroupID.replace("grp_","")
    }

    $ReqURL = "https://" + $Credentials.host + "/cprg/v1/cpcodes?contractId=$ContractID&groupID=$GroupID&productID=$ProductID&name=$Name&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result.cpcodes   
    }
    catch {
        return $_
    }
}