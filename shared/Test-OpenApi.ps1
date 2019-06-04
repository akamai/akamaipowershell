function Test-OpenAPI
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Path,
        [Parameter(Mandatory=$false)] [string] $Method = 'GET',
        [Parameter(Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($AccountSwitchKey)
    {
        if($Path.Contains("?"))
        {
            $Path += "&accountSwitchKey=$AccountSwitchKey"
        }
        else {
            $Path += "?accountSwitchKey=$AccountSwitchKey"
        }
    }

    try {
        if($Body) {
            $Result = Invoke-AkamaiRestMethod -Method $Method -Path $Path -Body $Body -EdgeRcFile $EdgeRCFile -Section $Section
        }
        else {
            $Result = Invoke-AkamaiRestMethod -Method $Method -EdgeRcFile $EdgeRCFile -Section $Section
        }
    }
    catch {
        throw $_
    }

    return $Result
}