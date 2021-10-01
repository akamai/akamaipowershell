#************************************************************************
#
#	Name: AkamaiPowershell.psm1
#	Author: S Macleod
#	Purpose: Standard methods to interact with Luna API
#	Date: 21/11/18
#	Version: 3 - Moved to .edgerc support
#
#************************************************************************

$Directories = Get-ChildItem $PSScriptRoot -exclude examples,pester | Where { $_.PSIsContainer }
$PS1Files = @()
$Directories | foreach { $PS1Files += Get-ChildItem "$_\*.ps1" }
$PS1Files | foreach { . $_.FullName }
$PS1Files | foreach { Export-ModuleMember $_.BaseName }

# Alias all List- cmdlets to Get- also for ease of use
$PS1Files | Where {$_.Name.StartsWith('List-')} | foreach {
    $CmdletName = $_.BaseName
    $GetAlias = $CmdletName.Replace("List-", "Get-")
    Set-Alias -Name $GetAlias -Value $CmdletName
    Export-ModuleMember -Function $CmdletName -Alias $GetAlias
}

# Alias Remove-Zone to Submit-BulkZoneDeleteRequest until such time as there is
# an actual non-bulk zone delete endpoint
Set-Alias -Name 'Remove-Zone' -Value 'New-BulkZoneDeleteRequest'
Export-ModuleMember -Function 'New-BulkZoneDeleteRequest' -Alias 'Remove-Zone'

# GTM Config aliases
Set-Alias -Name 'New-GTMDomainASMap' -Value 'Set-GTMDomainASMap'
Set-Alias -Name 'New-GTMDomainDatacenter' -Value 'Set-GTMDomainDatacenter'
Set-Alias -Name 'New-GTMDomainGeoMap' -Value 'Set-GTMDomainGeoMap'
Set-Alias -Name 'New-GTMDomainProperty' -Value 'Set-GTMDomainProperty'
Set-Alias -Name 'New-GTMDomainResource' -Value 'Set-GTMDomainResource'
Export-ModuleMember -Function 'New-GTMDomainASMap' -Alias 'Set-GTMDomainASMap'
Export-ModuleMember -Function 'New-GTMDomainDatacenter' -Alias 'Set-GTMDomainDatacenter'
Export-ModuleMember -Function 'New-GTMDomainGeoMap' -Alias 'Set-GTMDomainGeoMap'
Export-ModuleMember -Function 'New-GTMDomainProperty' -Alias 'Set-GTMDomainProperty'
Export-ModuleMember -Function 'New-GTMDomainResource' -Alias 'Set-GTMDomainResource'