function Delete-CacheByCPCode
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $CPCode,
        [Parameter(Mandatory=$false)] [string] $Network = 'production',
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'ccu',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $PostBody = @{ objects = @("$CPCode") }
    $PostJson = $PostBody | ConvertTo-Json -Depth 100
    $Path = "/ccu/v3/delete/cpcode/$Network`?accountSwitchKey=$AccountSwitchKey"

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