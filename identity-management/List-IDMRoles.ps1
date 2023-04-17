function List-IDMRoles
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $Actions,
        [Parameter(Mandatory=$false)] [int] $GroupID,
        [Parameter(Mandatory=$false)] [switch] $IgnoreContext,
        [Parameter(Mandatory=$false)] [switch] $Users,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $ActionsString = $Actions.IsPresent.ToString().ToLower()
    $IgnoreContextString = $IgnoreContext.IsPresent.ToString().ToLower()
    $UsersString = $Users.IsPresent.ToString().ToLower()
    if(!$Actions){ $ActionsString = '' }
    if(!$IgnoreContext){ $IgnoreContextString = '' }
    if(!$Users){ $UsersString = '' }

    $Path = "/identity-management/v2/user-admin/roles?actions=$ActionsString&groupId=$GroupID&ignoreContext=$IgnoreContextString&users=$UsersString"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
