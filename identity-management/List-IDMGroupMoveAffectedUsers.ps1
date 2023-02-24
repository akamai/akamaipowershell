function List-IDMGroupMoveAffectedUsers
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $SourceGroupID,
        [Parameter(Mandatory=$true)]  [string] $DestinationGroupID,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('lostAccess', 'gainAccess')] $UserType,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/identity-management/v2/user-admin/groups/move/$SourceGroupID/$DestinationGroupID/affected-users?userType=$UserType"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
