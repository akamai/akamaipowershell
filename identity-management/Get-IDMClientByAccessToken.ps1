function Get-IDMClientByAccessToken
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    $Auth = Parse-EdgeRCFile -EdgeRCFile $EdgeRCFile -Section $Section
    $Path = "/identity-management/v1/open-identities/tokens/$($Auth.ClientAccessToken)"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.identity
    }
    catch {
        throw $_
    }
}
