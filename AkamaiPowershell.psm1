#************************************************************************
#
#	Name: AkamaiPowershell.psm1
#	Author: S Macleod
#	Purpose: Standard methods to interact with Luna API
#	Date: 21/11/18
#	Version: 3 - Moved to .edgerc support
#
#************************************************************************

Get-ChildItem $PSScriptRoot\*.ps1 -Recurse | foreach { . $_.FullName }
Get-ChildItem $PSScriptRoot\*.ps1 -Recurse -Exclude "private" | foreach { Export-ModuleMember $_.BaseName }