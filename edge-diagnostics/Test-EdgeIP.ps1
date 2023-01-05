function Test-EdgeIP
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $IPAddresses,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edge-diagnostics/v1/verify-edge-ip?accountSwitchKey=$AccountSwitchKey"
    $BodyObj = @{
        ipAddresses = ($IPAddresses -split ',')
    }
    $Body = ConvertTo-Json $BodyObj

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.results
    }
    catch {
        throw $_
    }
}