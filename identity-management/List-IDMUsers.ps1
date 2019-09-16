function List-IDMUsers
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $Actions,
        [Parameter(Mandatory=$false)] [switch] $AuthGrants,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $ActionsString = $Actions.IsPresent.ToString().ToLower()
    $AuthGrantsString = $AuthGrants.IsPresent.ToString().ToLower()
    if(!$Actions){ $ActionsString = '' }
    if(!$AuthGrants){ $AuthGrantsString = '' }

    $Path = "/identity-management/v2/user-admin/ui-identities?actions=$ActionsString&authGrants=$AuthGrantsString&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}