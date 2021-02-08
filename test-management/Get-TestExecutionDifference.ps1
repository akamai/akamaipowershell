function Get-TestExecutionDifference
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $TestDefinitionExecutionID,
        [Parameter(Mandatory=$true)]  [string] $DifferenceID,
        [Parameter(Mandatory=$false)] [switch] $Raw,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/test-management/v1/test-definition-executions/$TestDefinitionExecutionID/differences/$DifferenceID`?accountSwitchKey=$AccountSwitchKey"
    if($Raw)
    {
        $Path = $Path.Replace($DifferenceID,"$DifferenceID/raw-request-response")
    }
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception 
    }
}