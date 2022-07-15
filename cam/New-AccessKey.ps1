function New-AccessKey
{
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)]  [string] $AccessKey,
        [Parameter(Mandatory=$true,ParameterSetName='body')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/cam/v1/access-keys?accountSwitchKey=$AccountSwitchKey"
        if($AccessKey){
            $Body = ConvertTo-Json $AccessKey -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_.Exception
        }
    }

    end{}
}