function Restore-TestRequirement
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $RequirementID,
        [Parameter(Mandatory=$false)] [switch] $RestoreChildResources,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $RestoreChildResourcesString = $RestoreChildResources.IsPresent.ToString().ToLower()
    if(!$RestoreChildResources){ $RestoreChildResourcesString = '' }

    $Path = "/test-management/v2/functional/requirements/$RequirementID/restore?restoreChildResources=$RestoreChildResourcesString"

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_ 
    }
}
