function New-EdgeMTR
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Destination,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('IP','HOST')] $DestinationType,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('ICMP','TCP')] $PacketType,
        [Parameter(Mandatory=$false)] [int] [ValidateSet(80,443)] $Port,
        [Parameter(Mandatory=$false)] [switch] $ResolveDNS,
        [Parameter(Mandatory=$false)] [switch] $ShowIPs,
        [Parameter(Mandatory=$false)] [switch] $ShowLocations,
        [Parameter(Mandatory=$false)] [string] $SiteShieldHostname,
        [Parameter(Mandatory=$true)]  [string] $Source,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('EDGE_IP','LOCATION')] $SourceType,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edge-diagnostics/v1/mtr?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{
        destination = $Destination
        destinationType = $DestinationType
        packetType = $PacketType
        resolveDns = $ResolveDNS.IsPresent
        showIps = $ShowIPs.IsPresent
        showLocations = $ShowLocations.IsPresent
    }


    if($Port){
        $BodyObj['port'] = $Port 
    }

    if($SiteShieldHostname -ne ''){
        $BodyObj['siteShieldHostname'] = $SiteShieldHostname 
    }

    if($Source -ne ''){
        $BodyObj['source'] = $Source 
    }

    if($SourceType -ne ''){
        $BodyObj['sourceType'] = $SourceType 
    }

    $Body = ConvertTo-Json $BodyObj

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}