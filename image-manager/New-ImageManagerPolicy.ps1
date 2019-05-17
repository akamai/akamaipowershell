function New-ImageManagerPolicy
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicySetAPIKey,
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('Staging', 'Production')]$Network,
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'image-manager',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -EdgeRCFile $EdgeRCFile -Section $Section
    if(!$Credentials){ return $null }

    if($AccountSwitchKey)
    {
        Write-Host -ForegroundColor Yellow "Image Manager API currently does not support Account Switching. Sorry"
        return
        #?accountSwitchKey=$AccountSwitchKey
    }


    try {
        $ExistingPolicy = Get-ImageManagerPolicy -PolicySetAPIKey $PolicySetAPIKey -PolicyID $PolicyID -EdgeRCFile $EdgeRCFile -Section $Section #-AccountSwitchKey $AccountSwitchKey
        if($ExistingPolicy)
        {
            Write-Host -ForegroundColor Yellow "Polcicy $PolicyID already exists in Policy Set $PolicySetAPIKey. Nothing to do"
            return
        }
    }
    catch {
        
    }

    $ReqURL = "https://" + $Credentials.host + "/imaging/v2/policies/$PolicyID"
    if($Network.ToLower() -eq "staging")
    {
        $ReqURL = "https://" + $Credentials.host.Replace(".imaging.",".imaging-staging.") + "/imaging/v2/policies/$PolicyID"
    }
    $AdditionalHeaders = @{ 'Luna-Token' = $PolicySetAPIKey }

    try {
        $Result = Invoke-AkamaiOPEN -Method PUT -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -AdditionalHeaders $AdditionalHeaders -Body $Body
        return $Result
    }
    catch {
        throw $_.Exception
    }
}

