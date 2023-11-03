function List-TopLevelGroups
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    try {
        $Groups = List-Groups -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey | Where {$_.parentGroupId -eq $null}
        return $Groups 
    }
    catch {
        throw $_
    }           
}
