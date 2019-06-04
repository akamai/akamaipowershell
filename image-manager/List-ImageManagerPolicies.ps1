function List-ImageManagerPolicies
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicySetAPIKey,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('Staging', 'Production')]$Network,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'image-manager',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($AccountSwitchKey)
    {
        Write-Host -ForegroundColor Yellow "Image Manager API currently does not support Account Switching. Sorry"
        return
        #?accountSwitchKey=$AccountSwitchKey
    }

    $Path = "/imaging/v2/policies"
    if($Network.ToLower() -eq "staging")
    {
        $ReqURL = "https://" + $Credentials.host.Replace(".imaging.",".imaging-staging.") + "/imaging/v2/policies/$PolicyID"
    }
    $AdditionalHeaders = @{ 'Luna-Token' = $PolicySetAPIKey }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AdditionalHeaders $AdditionalHeaders
        return $Result.items
    }
    catch {
        throw $_.Exception
    }
}

