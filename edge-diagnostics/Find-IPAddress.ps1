function Find-IPAddress
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $IPAddresses,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edge-diagnostics/v1/locate-ip"
    $BodyObj = @{
        ipAddresses = ($IPAddresses -split ',')
    }
    $Body = ConvertTo-Json $BodyObj

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.results
    }
    catch {
        throw $_
    }
}
