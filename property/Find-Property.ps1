function Find-Property
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PropertyName,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/search/find-by-value?accountSwitchKey=$AccountSwitchKey"
    $Body = @{propertyName = $PropertyName}
    $JsonBody = $Body | ConvertTo-Json -Depth 10 

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $JsonBody
        return $Result
    }
    catch {
        throw $_.Exception
    }
}

