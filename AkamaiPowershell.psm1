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

# Datastream aliases
Set-Alias -Name Activate-DS2Stream -Value Activate-DataStream
Set-Alias -Name Deactivate-DS2Stream -Value Deactivate-DataStream
Set-Alias -Name Get-DS2ActivationHistory -Value Get-DatastreamActivationHistory
Set-Alias -Name Get-DS2StreamHistory -Value Get-DataStreamHistory
Set-Alias -Name Get-DS2StreamVersion -Value Get-DataStreamVersion
Set-Alias -Name List-DS2Connectors -Value List-DataStreamConnectors
Set-Alias -Name List-DS2DatasetFields -Value List-DataStreamDatasetFields
Set-Alias -Name List-DS2Groups -Value List-DataStreamGroups
Set-Alias -Name List-DS2Products -Value List-DataStreamProducts
Set-Alias -Name List-DS2Streams -Value List-DataStream
Set-Alias -Name List-DS2StreamTypes -Value List-DataStreamTypes
Set-Alias -Name New-DS2Stream -Value New-DataStream
Set-Alias -Name Remove-DS2Stream -Value Remove-DataStream
Set-Alias -Name Set-DS2Stream -Value Set-DataStream

# Set module version env variable, used in custom UA, and check for updates
$Exp = Get-Content -Raw $PSScriptRoot\AkamaiPowershell.psd1
$Details = Invoke-Expression $Exp
$Env:AkamaiPowershellVersion = $Details.ModuleVersion

$Modules = Get-Module AkamaiPowershell -ListAvailable | Sort-Object -Property Version -Descending
if([System.Version]($Modules[0].Version) -gt [System.Version]($Details.ModuleVersion)){
    $WindowWidth = (Get-Host).UI.RawUI.MaxWindowSize.Width
    $MessageLength = 104
    $Dashes = '--------------------------------------------------------------------------------------------------------'
    if($WindowWidth -lt $MessageLength){ $Dashes = $Dashes.Substring(0,$WindowWidth)}
    Write-Host -ForegroundColor Cyan $Dashes
    Write-Host -ForegroundColor White 'Note: A newer version of this module is available (' -NoNewline
    Write-Host -ForegroundColor Cyan  $Modules[0].Version -NoNewline
    Write-Host -ForegroundColor White '). To install run ' -NoNewLine
    Write-Host -ForegroundColor Cyan 'Update-Module AkamaiPowerShell'
    Write-Host -ForegroundColor Cyan $Dashes
}

Remove-Variable $Exp
$Details = $null