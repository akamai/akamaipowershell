function List-CPSProductionDeployments
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EnrollmentID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cps/v2/enrollments/$EnrollmentID/deployments/production?accountSwitchKey=$AccountSwitchKey"
    $AdditionalHeaders = @{
        'accept' = 'application/vnd.akamai.cps.deployment.v6+json'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }  
}