function List-IDMAccountSwitchKeys
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $SearchString,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    $Client = Get-IDMClientByAccessToken -EdgeRCFile $EdgeRCFile -Section $Section
    $OpenIdentityID = $Client.openIdentityId

    $EncodedSearchString = [System.Web.HttpUtility]::UrlEncode($SearchString)
    $Path = "/identity-management/v1/open-identities/$OpenIdentityID/account-switch-keys?search=$EncodedSearchString"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_ 
    }
}
