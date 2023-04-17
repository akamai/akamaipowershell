function List-TestConfigVersions
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $IncludeRecentlyDeleted,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $IncludeRecentlyDeletedString = $IncludeRecentlyDeleted.IsPresent.ToString().ToLower()
    if(!$IncludeRecentlyDeleted){ $IncludeRecentlyDeletedString = '' }

    $Path = "/test-management/v2/functional/config-versions?includeRecentlyDeleted=$IncludeRecentlyDeletedString"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_ 
    }
}
