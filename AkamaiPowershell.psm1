#************************************************************************
#
#	Name: AkamaiPowershell.psm1
#	Author: S Macleod
#	Purpose: Standard methods to interact with Luna API
#	Date: 21/11/18
#	Version: 3 - Moved to .edgerc support
#
#************************************************************************

Get-ChildItem $PSScriptRoot\*.ps1 -Recurse -exclude "*.tests.ps1" | foreach { . $_.FullName }
Get-ChildItem $PSScriptRoot\*.ps1 -Recurse -exclude "*.tests.ps1" | foreach { Export-ModuleMember $_.BaseName }

# Alias all List- cmdlets to Get- also for ease of use
Get-ChildItem $PSScriptRoot\List-*.ps1 -Recurse | foreach {
    $CmdletName = $_.BaseName
    $GetAlias = $CmdletName.Replace("List-", "Get-")
    Set-Alias -Name $GetAlias -Value $CmdletName
    Export-ModuleMember -Function $CmdletName -Alias $GetAlias
}