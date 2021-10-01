function List-LDSLogFormatsByType
{
    Param(
        [Parameter(Mandatory=$false)] [string] $LogSourceType = "cpcode-products",
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    Write-Host -ForegroundColor Yellow "Warning: This cmdlet is deprecated and will be removed in a future release. Please use List-LDSLogFormats instead"
    
    $Path = "/lds-api/v3/log-sources/$LogSourceType/log-formats?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}