function Get-ZoneTransferStatus
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Zones,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/config-dns/v2/zones/zone-transfer-status?accountSwitchKey=$AccountSwitchKey"

    $BodyObj = @{
        zones = ($Zones -split ",")
    }
    $Body = $BodyObj | ConvertTo-Json -Depth 100

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}