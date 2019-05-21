function List-NSUploadAccounts
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -EdgeRCFile $EdgeRCFile -Section $Section
    if(!$Credentials){ return $null }

    if($AccountSwitchKey)
    {
        Write-Host -ForegroundColor Yellow "NetStorage API currently does not support Account Switching. Sorry"
        return
    }

    $ReqURL = "https://" + $Credentials.host + "/storage/v1/upload-accounts?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result.items
    }
    catch {
        throw $_.Exception
    }
}