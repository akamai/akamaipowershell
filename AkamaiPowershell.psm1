#************************************************************************
#
#	Name: AkamaiPowershell.psm1
#	Author: S Macleod
#	Purpose: Standard methods to interact with Luna API
#	Date: 21/11/18
#	Version: 4 - Moved exports to build.ps1
#
#************************************************************************

## List script files, excluding certain directories
$PS1Files = Get-ChildItem $PSScriptRoot -exclude examples, pester | Where-Object { $_.PSIsContainer } | Get-ChildItem -Filter *.ps1
$PS1Files | ForEach-Object { . $_.FullName }

# Alias all List- cmdlets to Get- also for ease of use
$PS1Files | Where-Object { $_.Name.StartsWith('List-') } | ForEach-Object {
    $CmdletName = $_.BaseName
    $GetAlias = $CmdletName.Replace("List-", "Get-")
    Set-Alias -Name $GetAlias -Value $CmdletName
}

# Set module version env variable, used in custom UA, and check for updates
$ModuleData = Get-Content -Raw $PSScriptRoot\AkamaiPowershell.psd1
$Details = Invoke-Expression $ModuleData
$Env:AkamaiPowershellVersion = $Details.ModuleVersion

if ($null -eq $env:AkamaiPowerShellDisableUpdateCheck) {
    ## Can turn off the update check if desired
    $LatestVersion = Find-Module AkamaiPowerShell -Repository PSGallery
    if ($LatestVersion.count -gt 1) { $LatestVersion = $LatestVersion[0] } # FIx for multiple versions being returned on random occasions
    if ([System.Version]($LatestVersion.Version) -gt [System.Version]($Details.ModuleVersion)) {
        $WindowWidth = (Get-Host).UI.RawUI.MaxWindowSize.Width
        $MessageLength = 104
        $Dashes = '---------------------------------------------------------------------------------------------------------'
        if ($WindowWidth -lt $MessageLength) { $Dashes = $Dashes.Substring(0, $WindowWidth) }
        Write-Host -ForegroundColor Cyan $Dashes
        Write-Host -ForegroundColor White 'Note: A newer version of this module is available (' -NoNewline
        Write-Host -ForegroundColor Cyan  $LatestVersion.Version -NoNewline
        Write-Host -ForegroundColor White '). To install run ' -NoNewLine
        Write-Host -ForegroundColor Cyan 'Update-Module AkamaiPowerShell'
        Write-Host -ForegroundColor Cyan $Dashes
    }
    Remove-Variable $LatestVersion
}

Remove-Variable -Name ModuleData
Remove-Variable -Name Details