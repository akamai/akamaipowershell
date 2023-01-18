function Set-CloudletPolicyVersion
{
    [CmdletBinding(DefaultParameterSetName = 'attributes')]
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$true)]  [string] $Version,
        [Parameter(Mandatory=$true,ParameterSetName='attributes',ValueFromPipeline=$true)] [object] $Policy,
        [Parameter(Mandatory=$true,ParameterSetName='body')] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $MatchRuleFormat,
        [Parameter(Mandatory=$false)] [switch] $OmitRules,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        # Nullify false switches
        $OmitRulesString = $OmitRules.IsPresent.ToString().ToLower()
        if(!$OmitRules){ $OmitRulesString = '' }

        if($Version -eq 'latest'){
            $Version = (List-CloudletPolicyVersions -PolicyID $PolicyID -Pagesize 1 -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).Version
            Write-Debug "Found latest version = $Version"
        }

        if($Policy){
            $UpdateObj = @{
                description = $Policy.description
                matchRules = $Policy.matchRules.PSObject.Copy()
            }

            ### Sanitise
            foreach($Rule in $UpdateObj.matchRules){
                $Rule.PSObject.Members.Remove('location')

                ### RC-specific
                if($Rule.type -eq 'igMatchRule'){
                    $Rule.PSObject.Members.Remove('matchURL')
                }
            }

            $Body = $UpdateObj | ConvertTo-Json -Depth 100
        }

        $Path = "/cloudlets/api/v2/policies/$PolicyID/versions/$Version`?matchRuleFormat=$MatchRuleFormat&omitRules=$OmitRulesString&accountSwitchKey=$AccountSwitchKey"

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_
        }
    }

    end{}
}
