function Get-MetadataTrace
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $RequestID,
        [Parameter(Mandatory=$false)] [switch] $HTMLFormat,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/edge-diagnostics/v1/metadata-tracer/requests/$RequestID"

    if($HTMLFormat){
        $AdditionalHeaders = @{
            Accept = 'text/html'
        }
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
