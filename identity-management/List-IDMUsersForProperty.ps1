function List-IDMUsersForProperty
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PropertyID,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('lostAccess', 'gainAccess')] $UserType,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/identity-management/v2/user-admin/properties/$PropertyID/users?userType=$UserType&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
