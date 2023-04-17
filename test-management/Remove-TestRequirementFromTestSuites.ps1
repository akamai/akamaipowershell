function Remove-TestRequirementFromTestSuites
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $RequirementID,
        [Parameter(Mandatory=$true)]  [string] $TestSuiteIDs,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/test-management/v2/functional/requirements/$RequirementID/associations/test-suites/dissociate"
    $BodyObj = $TestSuiteIDs -split ","
    $Body = $BodyObj | ConvertTo-Json -Depth 100

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_ 
    }
}
