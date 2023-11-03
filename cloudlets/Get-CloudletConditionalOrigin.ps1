function Get-CloudletConditionalOrigin
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $OriginID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )
    
    Write-Host -ForegroundColor Yellow "WARNING: This cmdlet is deprecated and will be removed in a future release. Use Get-CloudletLoadBalancer going forward"

    $Path = "/cloudlets/api/v2/origins/$OriginID"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
