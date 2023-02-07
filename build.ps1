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

Import-Module AkamaiPowershell.psm1 -Force -DisableNameChecking

$PS1Files = Get-ChildItem $PSScriptRoot -exclude examples,pester | Where-Object { $_.PSIsContainer } | Get-ChildItem -Filter *.ps1
$Aliases = New-Object -TypeName System.Collections.ArrayList
foreach($File in $PS1Files){
    try{
        $Alias = Get-Alias -Definition $File.baseName -ErrorAction Stop
        if($Alias){
            $Aliases.Add($Alias.Name) | Out-Null
        }
    }
    catch{

    }
}

Update-ModuleManifest -Path .\AkamaiPowershell.psd1 -ModuleVersion $Version -FunctionsToExport $PS1Files.BaseName -AliasesToExport $Aliases