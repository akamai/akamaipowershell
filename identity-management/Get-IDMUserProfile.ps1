function Get-IDMUserProfile
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $Actions,
        [Parameter(Mandatory=$false)] [switch] $AuthGrants,
        [Parameter(Mandatory=$false)] [switch] $Notifications,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -EdgeRCFile $EdgeRCFile -Section $Section
    if(!$Credentials){ return $null }

    # nullify false switches
    $ActionsString = $Actions.IsPresent.ToString().ToLower()
    $AuthGrantsString = $AuthGrants.IsPresent.ToString().ToLower()
    $NotificationsString = $Notifications.IsPresent.ToString().ToLower()
    if(!$Actions){ $ActionsString = '' }
    if(!$AuthGrants){ $AuthGrantsString = '' }
    if(!$Notifications){ $NotificationsString = '' }

    $ReqURL = "https://" + $Credentials.host + "/identity-management/v2/user-profile?actions=$ActionsString&authGrants=$AuthGrantsString&notifications=$NotificationsString"
    
    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result
    }
    catch {
        throw $_.Exception  
    }
}

