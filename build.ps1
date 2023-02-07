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
    [Parameter(Mandatory=$true)] [string] $Version
)

Import-Module AkamaiPowerShell.psd1 -Force -DisableNameChecking

$Functions = Get-Command -Module AkamaiPowershell -CommandType Function
$Aliases = Get-Command -Module AkamaiPowershell -CommandType Alias
Update-ModuleManifest -Path .\AkamaiPowershell.psd1 -ModuleVersion $Version -FunctionsToExport $Functions -AliasesToExport $Aliases