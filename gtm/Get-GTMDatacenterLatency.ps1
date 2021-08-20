function Get-GTMDatacenterLatency
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Domain,
        [Parameter(Mandatory=$true)]  [string] $DatacenterID,
        [Parameter(Mandatory=$true)]  [string] $Start,
        [Parameter(Mandatory=$true)]  [string] $End,
        [Parameter(Mandatory=$false)] [string] $Latency,
        [Parameter(Mandatory=$false)] [string] $Loss,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $DateTimeMatch = '[\d]{4}-[\d]{2}-[\d]{2}T[\d]{2}:[\d]{2}:[\d]{2}Z'
    if(($Start -and $Start -notmatch $DateTimeMatch) -or ($End -and $End -notmatch $DateTimeMatch)){
        throw "ERROR: Start & End must be in the format 'YYYY-MM-DDThh:mm:ssZ'"
    }

    $Path = "/gtm-api/v1/reports/latency/domains/{domain}/datacenters/$DatacenterID`?start=$Start&end=$End&latency=$Latency&loss=$Loss&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}

