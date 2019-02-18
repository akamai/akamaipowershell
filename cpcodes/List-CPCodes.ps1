function List-CPCodes
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey,
        [Parameter(Mandatory=$false)] [string] $ContractID,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ProductID,
        [Parameter(Mandatory=$false)] [string] $Name
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/cprg/v1/cpcodes"
    $QueryParams = @()

    if($AccountSwitchKey){ $QueryParams += "accountSwitchKey=$AccountSwitchKey" }
    if($ContractID)
    { 
        # Remove ctr_ prefix from contract ID
        $ContractID = $ContractID.Replace("ctr_","")
        $QueryParams += "contractId=$ContractID" 
    }
    if($GroupID)
    { 
        # Remove grp_ prefix from group id
        $GroupID = $GroupID.replace("grp_","")
        $QueryParams += "groupID=$GroupID" 
    }
    if($ProductID){ $QueryParams += "productID=$ProductID" }
    if($Name){ $QueryParams += "name=$Name" }

    if($QueryParams.Count -gt 0)
    {
        $QueryString = "?"
        $QueryString += $QueryParams -join "&"
        $ReqURL += $QueryString
    }

    $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
    
    return $Result.cpcodes     
}

