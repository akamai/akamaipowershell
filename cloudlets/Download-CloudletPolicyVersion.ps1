function Download-CloudletPolicyVersion
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PolicyID,
        [Parameter(Mandatory=$true)]  [string] $Version,
        [Parameter(Mandatory=$false)] [string] $OutputFileName,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($Version -eq 'latest'){
        $Version = (List-CloudletPolicyVersions -PolicyID $PolicyID -Pagesize 1 -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).Version
        Write-Debug "Found latest version = $Version"
    }

    $Path = "/cloudlets/api/v2/policies/$PolicyID/versions/$Version/download"

    $AdditionalHeaders = @{
        Accept = "*/*"
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey -AdditionalHeaders $AdditionalHeaders

        if($OutputFileName -eq ''){
            $Lines = $Result -split "`n"
            $PolicyName = $Lines | where {$_.contains("Policy:")}
            $PolicyName = $PolicyName.replace("# Policy: ","")
            $PolicyName = $PolicyName.Trim()
            $OutputFileName = "$PolicyName-v$Version.csv"
        }

        $Result | Out-File $OutputFileName -Encoding ascii
        Write-Host "Wrote version " -ForegroundColor Green -NoNewLine
        Write-Host $Version -NoNewLine
        Write-Host " of policy ID "  -ForegroundColor Green -NoNewLine
        Write-Host $PolicyID -NoNewLine
        Write-Host " to "  -ForegroundColor Green -NoNewLine
        Write-Host $OutputFileName
        return
    }
    catch {
        throw $_
    }
}
