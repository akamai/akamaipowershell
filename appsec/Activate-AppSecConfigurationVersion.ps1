function Activate-AppSecConfigurationVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    Write-Host -ForegroundColor Yellow "WARNING: This cmdlet is deprecated and will be removed in a future release. Use Activate-AppSecConfiguration"

    $Path = "/appsec/v1/activations"

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -Body $Body
        return $Result
    }
    catch {
        throw $_ 
    }
}
