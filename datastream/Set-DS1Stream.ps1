function Set-DS1Stream
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $StreamID,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)]  [object] $Stream,
        [Parameter(Mandatory=$true,ParameterSetName='postbody')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/datastream-config-api/v1/datastream1/streams/$StreamID`?groupId=$GroupID&streamStatus=$StreamStatus&accountSwitchKey=$AccountSwitchKey"

        if($Stream){
            $Body = ConvertTo-Json -Depth 100 $Stream
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_
        }
    }

    end{}
}
