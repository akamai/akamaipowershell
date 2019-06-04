function List-IDMRoles
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $Actions,
        [Parameter(Mandatory=$false)] [int] $GroupID,
        [Parameter(Mandatory=$false)] [switch] $IgnoreContext,
        [Parameter(Mandatory=$false)] [switch] $Users,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $ActionsString = $Actions.IsPresent.ToString().ToLower()
    $IgnoreContextString = $IgnoreContext.IsPresent.ToString().ToLower()
    $UsersString = $Users.IsPresent.ToString().ToLower()
    if(!$Actions){ $ActionsString = '' }
    if(!$IgnoreContext){ $IgnoreContextString = '' }
    if(!$Users){ $UsersString = '' }

    $Path = "/identity-management/v2/user-admin/roles?actions=$ActionsString&groupId=$GroupID&ignoreContext=$IgnoreContextString&users=$UsersString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}