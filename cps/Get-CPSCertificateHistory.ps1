function Get-CPSCertificateHistory
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $EnrollmentID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cps/v2/enrollments/$EnrollmentID/history/certificates?accountSwitchKey=$AccountSwitchKey"
    $AdditionalHeaders = @{
        'accept' = 'application/vnd.akamai.cps.certificate-history.v1+json'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.certificates
    }
    catch {
        throw $_.Exception
    }  
}