function List-LDSFTPCPCodes
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'default'
    )
    
    $Results = @()
    $LogConfigurations = Get-LDSLogSources -Section $Section
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

