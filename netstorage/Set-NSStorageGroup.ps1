function Set-NSStorageGroup
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $StorageGroupID,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)] [System.Object] $StorageGroup,
        [Parameter(Mandatory=$true,ParameterSetName='body')] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process {
        $Path = "/storage/v1/storage-groups/$StorageGroupID"
        try {
            if($StorageGroup){
                $Body = $StorageGroup | ConvertTo-Json -Depth 100
            }
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -Body $Body
            return $Result
        }
        catch {
            throw $_
        }
    }

    end{}
}
