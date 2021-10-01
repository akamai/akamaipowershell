function New-TestSuite
{
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='pipieline',ValueFromPipeline=$true)]  [object] $TestSuite,
        [Parameter(Mandatory=$true,ParameterSetName='body')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/test-management/v2/functional/test-suites?accountSwitchKey=$AccountSwitchKey"

        if($TestSuite){
            $Body = $TestSuite | ConvertFrom-Json -Depth 100
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