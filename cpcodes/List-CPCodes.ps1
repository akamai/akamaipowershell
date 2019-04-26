function List-CPCodes
{
    Param(
        [Parameter(Mandatory=$false)] [string] $ContractID,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ProductID,
        [Parameter(Mandatory=$false)] [string] $Name,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
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

    $ReqURL = "https://" + $Credentials.host + "/cprg/v1/cpcodes?contractId=$ContractID&groupId=$GroupID&productId=$ProductID&name=$Name&accountSwitchKey=$AccountSwitchKey"

    $ReqURL = "https://" + $Credentials.host + "/cprg/v1/cpcodes?accountSwitchKey=$AccountSwitchKey"
    if($ContractID){ $ReqURL += "&contractId=$ContractID"}
    if($GroupID)   { $ReqURL += "&groupId=$GroupID"      }
    if($ProductID) { $ReqURL += "&productId=$ProductID"  }
    if($Name)      { $ReqURL += "&name=$Name"            }

    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result.cpcodes
    }
    catch {
        throw $_.Exception
    }
}