function New-ErrorTranslation
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ErrorCode,
        [Parameter(Mandatory=$false)] [switch] $TraceFormwardLogs,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edge-diagnostics/v1/error-translator?accountSwitchKey=$AccountSwitchKey"
    $BodyObj = @{
        errorCode = $ErrorCode
        traceForwardLogs = $TraceFormwardLogs.IsPresent
    }
    $Body = ConvertTo-Json $BodyObj

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}