#************************************************************************
#
#	Name: List-LDSConfigsForCPCodes
#	Author: S Macleod
#	Purpose: Polls LDS API for find live configs for given cp codes
#	Date: 04/02/2019
#	Version: 1 - Initial
#
#************************************************************************

Param(
    [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
    [Parameter(Mandatory=$false)] [string] $Section = 'default',
    [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
)

$Results = New-Object -TypeName System.Collections.ArrayList
$LogSources = List-LDSLogSources -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
Write-Host "Found $($LogSources.count) sources to process"
for($i = 0; $i -lt $LogSources.count; $i++)
{
    $PercentComplete = ($i / $LogSources.Count * 100)
    $PercentComplete = [math]::Round($PercentComplete)
    Write-Progress -Activity "Listing LDS config..." -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete;

    $Source = $LogSources[$i]

    try{
        $Config = List-LDSLogConfigurationsForID -logSourceID $Source.id -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        if($null -ne $Config)
        {
            $Results.Add($Config) | Out-Null
        }
    }
    catch{
        Write-Host -ForegroundColor Yellow "Failed to get info for $($Source.cpcode)"
        Write-Host $_
    }
    
}

return $Results



