function Set-TestSuite
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $TestSuiteID,
        [Parameter(Mandatory=$true,ParameterSetName='pipieline',ValueFromPipeline=$true)]  [object] $TestSuite,
        [Parameter(Mandatory=$true,ParameterSetName='body')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/test-management/v2/functional/test-suites/$TestSuiteID"

        if($TestSuite){
            $Body = $TestSuite | ConvertFrom-Json -Depth 100
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
