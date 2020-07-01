function Set-NSUploadAccount
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $UploadAccountID,
        [Parameter(Mandatory=$false, ValueFromPipeline)] [System.Object] $UploadAccount,
        [Parameter(Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    process{
        $Path = "/storage/v1/upload-accounts/$UploadAccountID`?accountSwitchKey=$AccountSwitchKey"
        if($UploadAccount){
            $Body = $UploadAccount | ConvertTo-Json -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
            return $Result
        }
        catch {
            throw $_.Exception
        }
    }
}