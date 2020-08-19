function Get-MtrFromGhostLocation
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $LocationID,
        [Parameter(Mandatory=$true)]  [string] $DestinationDomain,
        [Parameter(Mandatory=$false)] [switch] $ResolveDNS,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $ResolveDNSString = $ResolveDNS.IsPresent.ToString().ToLower()
    if(!$ResolveDNS){ $ResolveDNSString = '' }

    $Path = "/diagnostic-tools/v2/ghost-locations/$LocationId/mtr-data?destinationDomain=$DestinationDomain&resolveDns=$ResolveDNSString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}