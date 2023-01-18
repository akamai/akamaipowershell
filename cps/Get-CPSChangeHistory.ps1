function Get-CPSChangeHistory
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $EnrollmentID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cps/v2/enrollments/$EnrollmentID/history/changes?accountSwitchKey=$AccountSwitchKey"
    $AdditionalHeaders = @{
        'accept' = 'application/vnd.akamai.cps.change-history.v5+json'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.changes
    }
    catch {
        throw $_
    }  
}
