function Add-TestCasesToTestSuite
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $TestSuiteID,
        [Parameter(Mandatory=$true)]  [string] $TestCaseIDs,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/test-management/v2/functional/test-suites/$TestSuiteID/associations/test-cases/associate"
    $BodyObj = $TestCaseIDs -split ","
    $Body = $BodyObj | ConvertTo-Json -Depth 100

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_ 
    }
}
