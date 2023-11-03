function List-ChinaCDNEdgeHostnames
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/chinacdn/v1/edge-hostnames"

    $AdditionalHeaders = @{
        Accept = 'application/vnd.akamai.chinacdn.edge-hostnames.v2+json'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.edgeHostnames
    }
    catch {
        throw $_ 
    }
}
