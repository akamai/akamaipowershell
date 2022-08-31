function Set-NSUploadAccount
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $UploadAccountID,
        [Parameter(Mandatory=$false,ParameterSetName='pipeline',ValueFromPipeline=$true)] [System.Object] $UploadAccount,
        [Parameter(Mandatory=$false,ParameterSetName='body')] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

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
            throw $_
        }
    }

    end{}
}