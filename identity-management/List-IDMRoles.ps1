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

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -EdgeRCFile $EdgeRCFile -Section $Section
    if(!$Credentials){ return $null }

    # nullify false switches
    $ActionsString = $Actions.IsPresent.ToString().ToLower()
    $IgnoreContextString = $IgnoreContext.IsPresent.ToString().ToLower()
    $UsersString = $Users.IsPresent.ToString().ToLower()
    if(!$Actions){ $ActionsString = '' }
    if(!$IgnoreContext){ $IgnoreContextString = '' }
    if(!$Users){ $UsersString = '' }

    $ReqURL = "https://" + $Credentials.host + "/identity-management/v2/user-admin/roles?actions=$ActionsString&groupId=$GroupID&ignoreContext=$IgnoreContextString&users=$UsersString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result
    }
    catch {
        throw $_.Exception
    }
}