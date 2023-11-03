function List-CloudletPolicyActivations
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$false)][ValidateSet('prod','staging')] [string] $Network,
        [Parameter(Mandatory=$false)] [string] $PropertyName,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $NetworkLower = $Network.ToLowerInvariant()

    $Path = "/cloudlets/api/v2/policies/$PolicyID/activations?network=$NetworkLower&propertyName=$PropertyName"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
