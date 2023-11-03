function List-ChinaCDNPropertyHostnames
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/chinacdn/v1/property-hostnames"

    $AdditionalHeaders = @{
        Accept = 'application/vnd.akamai.chinacdn.property-hostnames.v1+json'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.propertyHostnames
    }
    catch {
        throw $_ 
    }
}
