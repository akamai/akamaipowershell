function List-TCMSetCertificates
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $SetID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($AccountSwitchKey){
        throw "TCM API does not support account switching. Sorry"
    }

    $AdditionalHeaders = @{
        'accept' = 'application/prs.akamai.trust-chain-manager-api.set.v1+json'
    }

    $Path = "/trust-chain-manager/v1/sets/$SetID/certificates"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}