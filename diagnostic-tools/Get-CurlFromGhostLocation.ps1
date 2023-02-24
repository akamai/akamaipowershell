function Get-CurlFromGhostLocation
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $LocationID,
        [Parameter(Mandatory=$true)]  [string] $URL,
        [Parameter(Mandatory=$true)]  [string] $UserAgent,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/diagnostic-tools/v2/ghost-locations/{locationId}/curl-results"
    $PostObj = @{
        url = $URL
        userAgent = $UserAgent
    }
    $Body = $PostObj | ConvertTo-Json

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
