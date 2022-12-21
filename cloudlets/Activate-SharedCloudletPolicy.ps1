function Activate-SharedCloudletPolicy
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$true)]  [string] $Version,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('STAGING','PRODUCTION')] $Network,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($Version -eq 'latest'){
        $Version = (List-SharedCloudletPolicyVersions -PolicyID $PolicyID -Size 10 -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey)[0].Version
        Write-Debug "Found latest version = $Version"
    }

    $Path = "/cloudlets/v3/policies/$PolicyID/activations?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{ 
        operation = 'ACTIVATION'
        network = $Network.ToUpper()
        policyVersion = $Version
    }

    $Body = ConvertTo-Json $BodyObj -Depth 100

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
