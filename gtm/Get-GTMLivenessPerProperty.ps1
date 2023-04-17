function Get-GTMLivenessPerProperty
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Domain,
        [Parameter(Mandatory=$true)]  [string] $Property,
        [Parameter(Mandatory=$true)]  [string] $Date,
        [Parameter(Mandatory=$false)] [string] $AgentIP,
        [Parameter(Mandatory=$false)] [string] $TargetIP,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $DateMatch = '[\d]{4}-[\d]{2}-[\d]{2}'
    if($Date -and $Date -notmatch $DateMatch){
        throw "ERROR: Date must be in the format 'YYYY-MM-DD'"
    }

    $Path = "/gtm-api/v1/reports/liveness-tests/domains/$Domain/properties/$Property`?date=$Date&agentIp=$AgentIP&targetIp=$TargetIP"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
