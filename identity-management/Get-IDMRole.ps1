function Get-IDMRole
{
    Param(
        [Parameter(Mandatory=$false)] [string] $RoleID,
        [Parameter(Mandatory=$false)] [switch] $Actions,
        [Parameter(Mandatory=$false)] [switch] $GrantedRoles,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -EdgeRCFile $EdgeRCFile -Section $Section
    if(!$Credentials){ return $null }

    # nullify false switches
    $ActionsString = $Actions.IsPresent.ToString().ToLower()
    $GrantedRolesString = $GrantedRoles.IsPresent.ToString().ToLower()
    if(!$Actions){ $ActionsString = '' }
    if(!$GrantedRoles){ $GrantedRolesString = '' }

    $ReqURL = "https://" + $Credentials.host + "/identity-management/v2/user-admin/roles/$RoleID`?actions=$ActionsString&grantedRoles=$GrantedRolesString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiOPEN -Method GET -ClientToken $Credentials.client_token -ClientAccessToken $Credentials.access_token -ClientSecret $Credentials.client_secret -ReqURL $ReqURL
        return $Result
    }
    catch {
        throw $_.Exception
    }
}