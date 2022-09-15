function New-CloudletPolicyVersion
{
    [CmdletBinding(DefaultParameterSetName = 'attributes')]
    Param(
        [Parameter(Mandatory=$true) ] [string] $PolicyID,
        [Parameter(ParameterSetName='attributes', Mandatory=$true)]  [string] $Description,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [object[]] $MatchRules,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)] [string] $MatchRuleFormat,
        [Parameter(ParameterSetName='postbody', Mandatory=$false)]   [string] $Body,
        [Parameter(Mandatory=$false)] [string] $CloneVersion,
        [Parameter(Mandatory=$false)] [switch] $IncludeRules,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($CloneVersion -eq 'latest'){
        $CloneVersion = (List-CloudletPolicyVersions -PolicyID $PolicyID -Pagesize 1 -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).Version
        Write-Debug "Found latest cloneversion = $CloneVersion"
    }

    $Path = "/cloudlets/api/v2/policies/$PolicyID/versions?cloneVersion=$CloneVersion&includeRules=$IncludeRules&matchRuleFormat=$MatchRuleFormat&accountSwitchKey=$AccountSwitchKey"

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        $Post = @{}
        if($MatchRules){
            ## Remove unneeded members
            $MatchRules | foreach {
                if($_.matchURL){
                    $_.PsObject.Members.Remove('matchURL')
                }
                if($_.location){
                    $_.PsObject.Members.Remove('location')
                }
            }
            $Post['matchRules'] = $MatchRules
        }

        if($MatchRuleFormat){
            $Post['matchRuleFormat'] = $MatchRuleFormat
        }

        if($Description){
            $Post['description'] = $Description
        }
        
        $Body = ConvertTo-Json $Post -Depth 10
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
        return $Result
    }
    catch {
        throw $_ 
    }
}
