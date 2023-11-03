function Get-GTMDomainGeoMap
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $DomainName,
        [Parameter(Mandatory=$true)]  [string] $MapName,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/config-gtm/v1/domains/$DomainName/geographic-maps/$MapName"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }  
}
