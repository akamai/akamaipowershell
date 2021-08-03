function Get-CloudletPolicyVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$true)]  [string] $Version,
        [Parameter(Mandatory=$false)] [string] $MatchRuleFormat,
        [Parameter(Mandatory=$false)] [switch] $OmitRules,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Nullify false switches
    $OmitRulesString = $OmitRules.IsPresent.ToString().ToLower()
    if(!$OmitRules){ $OmitRulesString = '' }

    $Path = "/cloudlets/api/v2/policies/$PolicyID/versions/$Version`?matchRuleFormat=$MatchRuleFormat&omitRules=$OmitRulesString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}