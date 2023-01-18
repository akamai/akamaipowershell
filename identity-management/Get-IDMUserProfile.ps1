function Get-IDMUserProfile
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $Actions,
        [Parameter(Mandatory=$false)] [switch] $AuthGrants,
        [Parameter(Mandatory=$false)] [switch] $Notifications,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    # nullify false switches
    $ActionsString = $Actions.IsPresent.ToString().ToLower()
    $AuthGrantsString = $AuthGrants.IsPresent.ToString().ToLower()
    $NotificationsString = $Notifications.IsPresent.ToString().ToLower()
    if(!$Actions){ $ActionsString = '' }
    if(!$AuthGrants){ $AuthGrantsString = '' }
    if(!$Notifications){ $NotificationsString = '' }

    $Path = "/identity-management/v2/user-profile?actions=$ActionsString&authGrants=$AuthGrantsString&notifications=$NotificationsString"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_  
    }
}
