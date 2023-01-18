function Restore-TestConfigVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ConfigVersionID,
        [Parameter(Mandatory=$true)]  [string] $RestoreChildResources,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $RestoreChildResourcesString = $RestoreChildResources.IsPresent.ToString().ToLower()
    if(!$RestoreChildResources){ $RestoreChildResourcesString = '' }

    $Path = "/test-management/v2/functional/config-versions/$ConfigVersionID/restore?restoreChildResources=$RestoreChildResourcesString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_ 
    }
}
