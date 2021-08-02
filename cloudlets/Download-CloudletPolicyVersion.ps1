function Download-CloudletPolicyVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$true)]  [string] $Version,
        [Parameter(Mandatory=$true)]  [string] $OutputFile,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/cloudlets/api/v2/policies/$PolicyID/versions/$Version/download?accountSwitchKey=$AccountSwitchKey"

    $AdditionalHeaders = @{
        Accept = "*/*"
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AdditionalHeaders $AdditionalHeaders
        $Result | Out-File $OutputFile -Encoding ascii
        Write-Host "Wrote version " -ForegroundColor Green -NoNewLine
        Write-Host $Version -NoNewLine
        Write-Host " of policy ID "  -ForegroundColor Green -NoNewLine
        Write-Host $PolicyID -NoNewLine
        Write-Host " to "  -ForegroundColor Green -NoNewLine
        Write-Host $OutputFile
        return
    }
    catch {
        throw $_.Exception
    }
}