function Restore-TestSuite
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $TestSuiteID,
        [Parameter(Mandatory=$false)] [string] $RestoreChildResources,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $RestoreChildResourcesString = $RestoreChildResources.IsPresent.ToString().ToLower()
    if(!$RestoreChildResources){ $RestoreChildResourcesString = '' }

    $Path = "/test-management/v2/functional/test-suites/$TestSuiteID/restore?restoreChildResources=$RestoreChildResourcesString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method DELETE -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_ 
    }
}
