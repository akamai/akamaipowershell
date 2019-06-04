function List-EdgeHostnames
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $ChinaCDNEnabled,
        [Parameter(Mandatory=$false)] [string] $Comments,
        [Parameter(Mandatory=$false)] [string] $CustomTarget,
        [Parameter(Mandatory=$false)] [string] $DNSZone,
        [Parameter(Mandatory=$false)] [switch] $IsEdgeIPBindingEnabled,
        [Parameter(Mandatory=$false)] [string] $Map,
        [Parameter(Mandatory=$false)] [string] $MapAlias,
        [Parameter(Mandatory=$false)] [string] $RecordNameSubstring,
        [Parameter(Mandatory=$false)] [string] $SecurityType,
        [Parameter(Mandatory=$false)] [string] $SlotNumber,
        [Parameter(Mandatory=$false)] [string] $TTL,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $ChinaCDNEnabledString = $ChinaCDNEnabled.IsPresent.ToString().ToLower()
    $IsEdgeIPBindingEnabledString = $IsEdgeIPBindingEnabled.IsPresent.ToString().ToLower()

    if(!$ChinaCDNEnabled){ $ChinaCDNEnabledString = '' }
    if(!$IsEdgeIPBindingEnabled){ $IsEdgeIPBindingEnabledString = ''}

    $Path = "/hapi/v1/edge-hostnames?chinaCdnEnabled=$ChinaCDNEnabledString&comments=$Comments&customTarget=$CustomTarget&dnsZone=$DNSZone&isEdgeIPBindingEnabled=$IsEdgeIPBindingEnabledString&map=$Map&mapAlias=$MapAlias&recordNameSubstring=$RecordNameSubstring&securityType=$SecurityType&slotNumber=$SlotNumber&ttl=$TTL&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.edgeHostnames
    }
    catch {
        throw $_.Exception
    }
}

