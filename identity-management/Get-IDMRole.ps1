function Get-IDMRole
{
    Param(
        [Parameter(Mandatory=$false)] [string] $RoleID,
        [Parameter(Mandatory=$false)] [switch] $Actions,
        [Parameter(Mandatory=$false)] [switch] $GrantedRoles,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $ActionsString = $Actions.IsPresent.ToString().ToLower()
    $GrantedRolesString = $GrantedRoles.IsPresent.ToString().ToLower()
    if(!$Actions){ $ActionsString = '' }
    if(!$GrantedRoles){ $GrantedRolesString = '' }

    $Path = "/identity-management/v2/user-admin/roles/$RoleID`?actions=$ActionsString&grantedRoles=$GrantedRolesString"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
