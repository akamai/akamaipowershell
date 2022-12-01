function Get-MetadataTrace
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $RequestID,
        [Parameter(Mandatory=$false)] [switch] $HTMLFormat,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edge-diagnostics/v1/metadata-tracer/requests/$RequestID`?accountSwitchKey=$AccountSwitchKey"

    if($HTMLFormat){
        $AdditionalHeaders = @{
            Accept = 'text/html'
        }
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}