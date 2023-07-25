function Get-HostnameAuditHistory {
    Param(
        [Parameter(Mandatory = $true)]  [string] $Hostname,
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/hostnames/$Hostname/audit-history"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.history.items
    }
    catch {
        throw $_
    }
}