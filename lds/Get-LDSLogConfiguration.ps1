function Get-LDSLogConfiguration
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $logConfigurationId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/lds-api/v3/log-configurations/$logConfigurationId`?accountSwitchKey=$AccountSwitchKey"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_ 
    }
}
