function Invalidate-CacheByURL
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $URL,
        [Parameter(Mandatory=$false)] [string] $Network = 'production',
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'ccu',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $PostBody = @{ objects = @("$URL") }
    $PostJson = $PostBody | ConvertTo-Json -Depth 100
    $Path = "/ccu/v3/invalidate/url/$Network`?accountSwitchKey=$AccountSwitchKey"

    try
    {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $PostJson
        return $Result
    }
    catch
    {
       throw $_.Exception 
    }
}

