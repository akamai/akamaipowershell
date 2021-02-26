function List-CloudletPolicyActivations
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$false)][ValidateSet('prod','staging')] [string] $Network,
        [Parameter(Mandatory=$false)] [string] $PropertyName,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $NetworkLower = $Network.ToLowerInvariant()

    $Path = "/cloudlets/api/v2/policies/$PolicyID/activations?network=$NetworkLower&propertyName=$PropertyName&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}