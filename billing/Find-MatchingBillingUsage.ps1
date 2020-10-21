function Find-MatchinBillingUsage
{
   Param(
        [Parameter(Mandatory=$true, ParameterSetName='postbody')] [string] $Body,
        [Parameter(Mandatory=$true, ParameterSetName='query',ValueFromPipeline=$true)] [Object] $Query,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        if($Query){
            $Body = $Query | ConvertTo-Json -Depth 100
        }

        $Path = "/billing-center-api/v2/measures/find?accountSwitchKey=$AccountSwitchKey"
    
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