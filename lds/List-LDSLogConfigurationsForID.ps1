function List-LDSLogConfigurationsForID
{
    Param(
        [Parameter(Mandatory=$false)] [string] [ValidateSet('cpcode-products','gtm-properties','edns-zones','answerx-objects')] $LogSourceType = "cpcode-products",
        [Parameter(Mandatory=$true)]  [string] $logSourceId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/lds-api/v3/log-sources/$LogSourceType/$logSourceId/log-configurations"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result 
    }
    catch {
        throw $_
    }
}
