function List-TestExecutions
{
    Param(
        [Parameter(Mandatory=$false)] [string] $TestDefinitionIDs,
        [Parameter(Mandatory=$false)] [switch] $LatestPerTestDefinition,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Nullify false switches
    $LatestPerTestDefinitionString = $LatestPerTestDefinition.IsPresent.ToString().ToLower()
    if(!$LatestPerTestDefinition){ $LatestPerTestDefinitionString = '' }

    $Path = "/test-management/v2/comparative/test-definition-executions?latestPerTestDefinition=$LatestPerTestDefinitionString&testDefinitionIds=$TestDefinitionIDs?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_ 
    }
}
