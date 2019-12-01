function List-CPSDeployments
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $EnrollmentID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cps/v2/enrollments/$EnrollmentID/deployments?accountSwitchKey=$AccountSwitchKey"
    $AdditionalHeaders = @{
        'accept' = 'application/vnd.akamai.cps.deployments.v6+json'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }  
}