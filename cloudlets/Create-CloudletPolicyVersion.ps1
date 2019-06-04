function Create-CloudletPolicyVersion
{
    Param(
        [Parameter(Mandatory=$true) ] [string] $PolicyID,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $Description,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [object[]] $MatchRules,
        [Parameter(Mandatory=$false)] [string] $CloneVersion,
        [Parameter(Mandatory=$false)] [switch] $IncludeRules,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $MatchRuleFormat,
        [Parameter(ParameterSetName='postbody', Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cloudlets/api/v2/policies/$PolicyID/versions?cloneVersion=$CloneVersion&includeRules=$IncludeRules&matchRuleFormat=$MatchRuleFormat&accountSwitchKey=$AccountSwitchKey"


    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        ## Remove unneeded member
        $MatchRules | foreach {
            $_.PsObject.Members.Remove('matchURL')
            $_.PsObject.Members.Remove('location')
        }
        
        $Post = @{ description = $Description; matchRuleFormat = $MatchRuleFormat; matchRules = $MatchRules }
        $Body = ConvertTo-Json $Post -Depth 10
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
        return $Result
    }
    catch {
        throw $_.Exception 
    }
}