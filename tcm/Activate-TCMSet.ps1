function Activate-TCMSet
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $SetID,
        [Parameter(Mandatory=$true)]  [string] $Version,
        [Parameter(Mandatory=$false)] [switch] $Staging,
        [Parameter(Mandatory=$false)] [switch] $Production,
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

    $Path = "/trust-chain-manager/v1/sets/$SetID/deployments"
    if($Version){
        $Path = "/trust-chain-manager/v1/sets/$SetID/deployments/versions/$Version"
    }

    $BodyObj = @{
        deployment = @{
            staging = $Staging.IsPresent
            production = $Production.IsPresent
        }
    }
    $Body = $BodyObj | ConvertTo-Json

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}