function Get-CurlFromGhostLocation
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $LocationID,
        [Parameter(Mandatory=$true)]  [string] $URL,
        [Parameter(Mandatory=$true)]  [string] $UserAgent,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/diagnostic-tools/v2/ghost-locations/{locationId}/curl-results?accountSwitchKey=$AccountSwitchKey"
    $PostObj = @{
        url = $URL
        userAgent = $UserAgent
    }
    $Body = $PostObj | ConvertTo-Json

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}