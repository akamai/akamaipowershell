
Param(
    [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
    [Parameter(Mandatory=$false)] [string] $Section = 'default',
    [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
)

$Results = New-Object -TypeName System.Collections.ArrayList
$LogSources = List-LDSLogSources -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
Write-Host "Found $($LogSources.count) sources to process"
foreach($LogSource in $LogSources)
{
    Write-Host $LogSource.cpcode
    $Config = List-LDSLogConfigurationsForID -Section $Section -logSourceID $LogSource.id
    if($Config -ne $null)
    {
        $Results.Add($Config) | Out-Null
    }
}

return $Results


