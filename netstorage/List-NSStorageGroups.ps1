function List-NSStorageGroups
{
    Param(
        [Parameter(Mandatory=$false)] [string] $CPCodeID,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('NETSTORAGE','EDGESTREAM','EDGESTREAM_IPHONE','ADAPTIVEEDGE','AD_INSERTION','CONTENT_PREPARATION','MSL_ORIGIN','FEO')] $StorageGroupPurpose,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/storage/v1/storage-groups?cpcodeId=$CPCodeID&storageGroupPurpose=$StorageGroupPurpose&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.items
    }
    catch {
        throw $_.Exception
    }
}