function Restore-TestSuite
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $TestSuiteID,
        [Parameter(Mandatory=$false)] [string] $RestoreChildResources,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $RestoreChildResourcesString = $RestoreChildResources.IsPresent.ToString().ToLower()
    if(!$RestoreChildResources){ $RestoreChildResourcesString = '' }

    $Path = "/test-management/v2/functional/test-suites/$TestSuiteID/restore?restoreChildResources=$RestoreChildResourcesString"

    try {
        $Result = Invoke-AkamaiRestMethod -Method DELETE -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_ 
    }
}
