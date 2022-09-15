function Get-GTMLivenessTestError
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ErrorCode,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/gtm-api/v1/reports/liveness-tests/error-code-descriptions/$ErrorCode`?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.items
    }
    catch {
        throw $_
    }
}


