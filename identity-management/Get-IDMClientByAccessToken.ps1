function Get-IDMClientByAccessToken
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )

    $Config = Get-Content $EdgeRCFile
    $ConfigIndex = [array]::indexof($Config,"[$Section]")
    $SectionArray = $Config[$ConfigIndex..($ConfigIndex + 4)]
    $SectionArray | ForEach-Object {
        if($_.ToLower().StartsWith("access_token")) { $ClientAccessToken = $_.Replace(" ","").SubString($_.IndexOf("=")) }
    }
    $Path = "/identity-management/v1/open-identities/tokens/$($ClientAccessToken)"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.identity
    }
    catch {
        throw $_.Exception
    }
}

