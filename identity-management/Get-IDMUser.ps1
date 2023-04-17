function Get-IDMUser
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $UIIdentityID,
        [Parameter(Mandatory=$false)] [switch] $Actions,
        [Parameter(Mandatory=$false)] [switch] $AuthGrants,
        [Parameter(Mandatory=$false)] [switch] $Notifications,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $ActionsString = $Actions.IsPresent.ToString().ToLower()
    $AuthGrantsString = $AuthGrants.IsPresent.ToString().ToLower()
    $NotificationsString = $Notifications.IsPresent.ToString().ToLower()
    if(!$Actions){ $ActionsString = '' }
    if(!$AuthGrants){ $AuthGrantsString = '' }
    if(!$Notifications){ $NotificationsString = '' }

    $Path = "/identity-management/v2/user-admin/ui-identities/$UIIdentityID`?actions=$ActionsString&authGrants=$AuthGrantsString&notifications=$NotificationsString"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
