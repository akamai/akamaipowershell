function List-CloudletPolicyVersions
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$false)] [string] $CloneVersion,
        [Parameter(Mandatory=$false)] [switch] $IncludeRules,
        [Parameter(Mandatory=$false)] [string] $MatchRuleFormat,
        [Parameter(Mandatory=$false)] [int]    $Offset,
        [Parameter(Mandatory=$false)] [int]    $Pagesize = 10,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Nullify false switches
    $IncludeRulesString = $IncludeRules.IsPresent.ToString().ToLower()
    if(!$IncludeRules){ $IncludeRulesString = '' }

    $Path = "/cloudlets/api/v2/policies/$PolicyID/versions?cloneVersion=$CloneVersion&includeRules=$IncludeRulesString&matchRuleFormat=$MatchRuleFormat&offset=$Offset&pageSize=$PageSize&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}