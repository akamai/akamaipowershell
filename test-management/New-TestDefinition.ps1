function New-TestDefinition
{
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)] [object] $TestDefinition,
        [Parameter(Mandatory=$true,ParameterSetName='requestbody')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/test-management/v2/functional/test-catalog/conditions/$TestDefinitionId`?accountSwitchKey=$AccountSwitchKey"

        if($TestDefinition){
            $Body = $TestDefinition | ConvertTo-Json -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_.Exception 
        }
    }

    end{}

}