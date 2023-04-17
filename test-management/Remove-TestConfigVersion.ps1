function Remove-TestConfigVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ConfigVersionID,
        [Parameter(Mandatory=$false)] [string] $DeleteChildResources,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $DeleteChildResourcesString = $DeleteChildResources.IsPresent.ToString().ToLower()
    if(!$DeleteChildResources){ $DeleteChildResourcesString = '' }

    $Path = "/test-management/v2/functional/config-versions/$ConfigVersionID`?deleteChildResources=$DeleteChildResourcesString"

    try {
        $Result = Invoke-AkamaiRestMethod -Method DELETE -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_ 
    }
}
