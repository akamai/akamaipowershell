function Get-CloudletPolicyVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$true)]  [string] $Version,
        [Parameter(Mandatory=$false)] [string] $MatchRuleFormat,
        [Parameter(Mandatory=$false)] [switch] $OmitRules,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Nullify false switches
    $OmitRulesString = $OmitRules.IsPresent.ToString().ToLower()
    if(!$OmitRules){ $OmitRulesString = '' }

    if($Version -eq 'latest'){
        $Version = (List-CloudletPolicyVersions -PolicyID $PolicyID -Pagesize 1 -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).Version
    }

    $Path = "/cloudlets/api/v2/policies/$PolicyID/versions/$Version`?matchRuleFormat=$MatchRuleFormat&omitRules=$OmitRulesString"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
