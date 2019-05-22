function List-NSStorageGroups
{
    Param(
        [Parameter(Mandatory=$false)] [string] $CPCodeID,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('NETSTORAGE','EDGESTREAM','EDGESTREAM_IPHONE','ADAPTIVEEDGE','AD_INSERTION','CONTENT_PREPARATION','MSL_ORIGIN','FEO')] $StorageGroupPurpose,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -EdgeRCFile $EdgeRCFile -Section $Section
    if(!$Credentials){ return $null }

    $ReqURL = "https://" + $Credentials.host + "/storage/v1/storage-groups?cpcodeId=$CPCodeID&storageGroupPurpose=$StorageGroupPurpose&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result.items
    }
    catch {
        throw $_.Exception
    }
}