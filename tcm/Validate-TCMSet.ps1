function Validate-TCMSet
{
    Param(
        [Parameter(Mandatory=$true, ParameterSetName='attributes', ValueFromPipeline=$true)] [string] $Set,
        [Parameter(Mandatory=$true, ParameterSetName='postbody')]   [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        if($AccountSwitchKey){
            throw "TCM API does not support account switching. Sorry"
        }
    
        $AdditionalHeaders = @{
            'accept' = 'application/prs.akamai.trust-chain-manager-api.set.v1+json'
        }
    
        $Path = "/trust-chain-manager/v1/sets/validator"
    
        if($Set){
            $Body = $Set | ConvertTo-Json -Depth 100
        }
    
        try {
            $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_.Exception
        }
    }

    end{}
}