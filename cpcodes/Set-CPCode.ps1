function Set-CPCode
{
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='postbody')]  [string] $CPCode,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)]  [object] $CPCodeObject,
        [Parameter(Mandatory=$true,ParameterSetName='postbody')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        if($CPCodeObject){
            $CPCode = $CPCodeObject.cpcodeId
            $Body = $CPCodeObject | ConvertTo-Json -Depth 100
        }
    
        $Path = "/cprg/v1/cpcodes/$CPCode`?accountSwitchKey=$AccountSwitchKey"
    
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


