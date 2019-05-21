function New-NSStorageGroup
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Body,
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

    $ReqURL = "https://" + $Credentials.host + "/storage/v1/storage-groups?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiOPEN -Method POST -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL -Body $Body
        return $Result
    }
    catch {
        throw $_.Exception
    }
}