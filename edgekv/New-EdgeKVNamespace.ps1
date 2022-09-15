function New-EdgeKVNamespace
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Name,
        [Parameter(Mandatory=$false)] [string] $RetentionInSeconds = 0,
        [Parameter(Mandatory=$false)] [string] [ValidateSet('US','EU','JP')] $GeoLocation = 'US',
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('STAGING','PRODUCTION')] $Network,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($Network -eq 'STAGING' -and $GeoLocation -ne 'US'){
        throw 'Only valid GeoLocation for STAGING network is US currently'
    }

    $Path = "/edgekv/v1/networks/$Network/namespaces?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{
        name = $Name
        geoLocation = $GeoLocation
        retentionInSeconds = $RetentionInSeconds
    }
    $Body = $BodyObj | ConvertTo-Json

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
