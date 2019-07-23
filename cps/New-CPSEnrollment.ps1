function New-CPSEnrollment
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ContractID,
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $DeployNotAfter,
        [Parameter(Mandatory=$false)] [string] $DeployNotBefore,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $DateMatch = '[\d]{4}-[\d]{2}-[\d]{2}'
    if(($DeployNotAfter -or $DeployNotBefore) -and ($DeployNotAfter -notmatch $DateMatch -or $DeployNotBefore -notmatch $DateMatch)){
        throw "ERROR: DeployNotAfter & DeployNotBefore must be in the format 'YYYY-MM-DD'"
    }

    $AdditionalHeaders = @{
        'accept' = 'application/vnd.akamai.cps.enrollment-status.v1+json'
        'content-type' = 'application/vnd.akamai.cps.enrollment.v7+json'
    }
    $Path = "/cps/v2/enrollments?contractId=$ContractID&deploy-not-after=$DeployNotAfter&deploy-not-before=$DeployNotBefore&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }  
}