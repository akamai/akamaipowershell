function Set-MSLStream
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $StreamID,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)]  [object] $Stream,
        [Parameter(Mandatory=$true,ParameterSetName='body')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/config-media-live/v2/msl-origin/streams/$StreamID"

        if($Stream){
            $Body = $Stream | ConvertTo-Json -depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            return $Result
        }
        catch {
            throw $_
        }
    }

    end{}
              
}
