function List-TCMSets
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Name,
        [Parameter(Mandatory=$false)] [switch] $DeployedOnStaging,
        [Parameter(Mandatory=$false)] [switch] $DeployedOnProduction,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($AccountSwitchKey){
        throw "TCM API does not support account switching. Sorry"
    }

    # nullify false switches
    $DeployedOnStagingString = $DeployedOnStaging.IsPresent.ToString().ToLower()
    if(!$DeployedOnStaging){ $DeployedOnStagingString = '' }
    $DeployedOnProductionString = $DeployedOnProduction.IsPresent.ToString().ToLower()
    if(!$DeployedOnProduction){ $DeployedOnProductionString = '' }

    $AdditionalHeaders = @{
        'accept' = 'application/prs.akamai.trust-chain-manager-api.set.v1+json'
    }

    $Path = "/trust-chain-manager/v1/sets?name=$Name&deployedOnStaging=$DeployedOnStagingString&deployedOnProduction=$DeployedOnProductionString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.sets
    }
    catch {
        throw $_
    }
}
