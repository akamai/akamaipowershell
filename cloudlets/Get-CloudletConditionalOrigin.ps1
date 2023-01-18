function Get-CloudletConditionalOrigin
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $OriginID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )
    
    Write-Host -ForegroundColor Yellow "WARNING: This cmdlet is deprecated and will be removed in a future release. Use Get-CloudletLoadBalancer going forward"

    $Path = "/cloudlets/api/v2/origins/$OriginID`?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
