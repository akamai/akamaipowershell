function Remove-TestSuite
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $TestSuiteID,
        [Parameter(Mandatory=$false)] [string] $DeleteChildResources,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $DeleteChildResourcesString = $DeleteChildResources.IsPresent.ToString().ToLower()
    if(!$DeleteChildResources){ $DeleteChildResourcesString = '' }

    $Path = "/test-management/v2/functional/test-suites/$TestSuiteID`?deleteChildResources=$DeleteChildResourcesString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method DELETE -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_ 
    }
}
