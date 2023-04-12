#------------------------------------------------------------------------
#
#	Name: build.ps1
#	Author: S Macleod
#	Purpose: Sets module data file with version, functions and aliases
#            to export
#	Date: 03/02/2023
#	Version: 1 - Initial
#
#------------------------------------------------------------------------

param(
    [Parameter(Mandatory = $false)] [string] $Version
)

Import-Module $PSScriptRoot\AkamaiPowershell.psm1 -Force -DisableNameChecking

$PS1Files = Get-ChildItem $PSScriptRoot -exclude examples, pester | Where-Object { $_.PSIsContainer } | Get-ChildItem -Filter *.ps1
$Aliases = New-Object -TypeName System.Collections.ArrayList
foreach ($File in $PS1Files) {
    try {
        $Alias = Get-Alias -Definition $File.baseName -ErrorAction Stop
        if ($Alias) {
            $Aliases.Add($Alias.Name) | Out-Null
        }
    }
    catch {

    }
}

$Params = @{
    Path              = 'AkamaiPowershell.psd1'
    FunctionsToExport = $PS1Files.BaseName
    AliasesToExport   = $Aliases
}
if ($Version) {
    $Params.ModuleVersion = $Version
}
Update-ModuleManifest @Params