function Get-IDMClientByAccessToken
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section
    )

    $Auth = Get-AkamaiCredentials -EdgeRCFile $EdgeRCFile -Section $Section
    $Path = "/identity-management/v1/open-identities/tokens/$($Auth.access_token)"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.identity
    }
    catch {
        throw $_
    }
}
