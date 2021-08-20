function Get-GTMLivenessPerProperty
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Domain,
        [Parameter(Mandatory=$true)]  [string] $Property,
        [Parameter(Mandatory=$true)]  [string] $Date,
        [Parameter(Mandatory=$false)] [string] $AgentIP,
        [Parameter(Mandatory=$false)] [string] $TargetIP,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $DateMatch = '[\d]{4}-[\d]{2}-[\d]{2}'
    if($Date -and $Date -notmatch $DateMatch){
        throw "ERROR: Date must be in the format 'YYYY-MM-DD'"
    }

    $Path = "/gtm-api/v1/reports/liveness-tests/domains/$Domain/properties/$Property`?date=$Date&agentIp=$AgentIP&targetIp=$TargetIP&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}

