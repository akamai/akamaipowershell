function Get-ReportType
{
    Param(
        [Parameter(Mandatory=$true)] [String] $ReportType,
        [Parameter(Mandatory=$true)] [String] $Version,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/reporting-api/v1/reports/$ReportType/versions/$Version"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
