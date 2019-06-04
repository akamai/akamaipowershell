function Get-IDMClientByAccessToken
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    $Path = "/identity-management/v1/open-identities/tokens/$($Credentials.access_token)"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.identity
    }
    catch {
        throw $_.Exception
    }
}

