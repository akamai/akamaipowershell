function List-TestExecutions
{
    Param(
        [Parameter(Mandatory=$false)] [string] $TestDefinitionIDs,
        [Parameter(Mandatory=$false)] [switch] $LatestPerTestDefinition,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Nullify false switches
    $LatestPerTestDefinitionString = $LatestPerTestDefinition.IsPresent.ToString().ToLower()
    if(!$LatestPerTestDefinition){ $LatestPerTestDefinitionString = '' }

    $Path = "/test-management/v2/comparative/test-definition-executions?latestPerTestDefinition=$LatestPerTestDefinitionString&testDefinitionIds=$TestDefinitionIDs"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_ 
    }
}
