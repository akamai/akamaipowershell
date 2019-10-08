function New-GTMDomainDatacenter
{
    Param(
        [Parameter(Mandatory=$false)] [string] $DomainName,
        [Parameter(Mandatory=$false)] [string] $DatacenterID,
        [Parameter(Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/config-gtm/v1/domains/$DomainName/datacenters/$DatacenterID`?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }  
}