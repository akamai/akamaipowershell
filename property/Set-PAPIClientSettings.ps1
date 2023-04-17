function Set-PAPIClientSettings
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $RuleFormat,
        [Parameter(Mandatory=$true)]  [bool]  $UsePrefixes,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $AcceptedRuleFormats = List-RuleFormats -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
    if($RuleFormat -notin $AcceptedRuleFormats){
        throw "$RuleFormat is not an accepted rule format. Run cmdlet List-RuleFormats for a full list"
    }

    $BodyObj = @{ 
        ruleFormat = $RuleFormat
        usePrefixes = $UsePrefixes
    }
    $Body = $BodyObj | ConvertTo-Json -Depth 100

    $Path = "/papi/v1/client-settings"

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
