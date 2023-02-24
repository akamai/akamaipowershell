function Test-OpenAPI
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Path,
        [Parameter(Mandatory=$false)] [string] $Method = 'GET',
        [Parameter(Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $Accept,
        [Parameter(Mandatory=$false)] [string] $ContentType,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($AccountSwitchKey)
    {
        if($Path.Contains("?"))
        {
            $Path += ""
        }
        else {
            $Path += ""
        }
    }

    $AdditionalHeaders = @{}

    if($Accept){
        $AdditionalHeaders['Accept'] = $Accept
    }

    if($ContentType){
        $AdditionalHeaders['Content-Type'] = $ContentType
    }

    try {
        if($Body) {
            $Result = Invoke-AkamaiRestMethod -Method $Method -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -AdditionalHeaders $AdditionalHeaders
        }
        else {
            $Result = Invoke-AkamaiRestMethod -Method $Method -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -AdditionalHeaders $AdditionalHeaders
        }
    }
    catch {
        throw $_
    }

    return $Result
}
