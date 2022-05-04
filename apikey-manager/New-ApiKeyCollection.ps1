function New-APIKeyCollection
{
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)] [Object] $Collection,
        [Parameter(Mandatory=$true,ParameterSetName='body')] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}
    
    process{
        if($Collection){
            $Body = $Collection | ConvertTo-Json -Depth 100
        }

        $Path = "/apikey-manager-api/v1/collections?accountSwitchKey=$AccountSwitchKey"

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