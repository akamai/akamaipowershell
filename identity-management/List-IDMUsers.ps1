function List-IDMUsers
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $Actions,
        [Parameter(Mandatory=$false)] [switch] $AuthGrants,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $ActionsString = $Actions.IsPresent.ToString().ToLower()
    $AuthGrantsString = $AuthGrants.IsPresent.ToString().ToLower()
    if(!$Actions){ $ActionsString = '' }
    if(!$AuthGrants){ $AuthGrantsString = '' }

    $Path = "/identity-management/v2/user-admin/ui-identities?actions=$ActionsString&authGrants=$AuthGrantsString&groupId=$GroupID"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
