function Test-OpenAPI
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Path,
        [Parameter(Mandatory=$false)] [string] $Method = 'GET',
        [Parameter(Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $Accept,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
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

    if($Accept){
        $AdditionalHeaders = @{
            Accept = $Accept
        }
    }

    try {
        if($Body) {
            $Result = Invoke-AkamaiRestMethod -Method $Method -Path $Path -Body $Body -EdgeRcFile $EdgeRCFile -Section $Section -AdditionalHeaders $AdditionalHeaders
        }
        else {
            $Result = Invoke-AkamaiRestMethod -Method $Method -Path $Path -EdgeRcFile $EdgeRCFile -Section $Section -AdditionalHeaders $AdditionalHeaders
        }
    }
    catch {
        throw $_
    }

    return $Result
}