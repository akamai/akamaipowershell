function List-LDSFTPCPCodes
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )
    
    $Results = @()
    $LogConfigurations = Get-LDSLogSources -Section $Section -AccountSwitchKey $AccountSwitchKey
    foreach($CP in $LogConfigurations)
    {
        $Config = List-LDSLogConfigurationForID -Section $Section -logSourceID $CP.id
        if($Config -ne $null)
        {
            $Results += $Config
        }
    }

    return $Results
}

