function New-ErrorTranslation
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ErrorCode,
        [Parameter(Mandatory=$false)] [switch] $TraceFormwardLogs,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edge-diagnostics/v1/error-translator"
    $BodyObj = @{
        errorCode = $ErrorCode
        traceForwardLogs = $TraceFormwardLogs.IsPresent
    }
    $Body = ConvertTo-Json $BodyObj

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
