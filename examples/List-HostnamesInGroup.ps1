#************************************************************************
#
#	Name: List-HostnamesInGroup
#	Author: S Macleod
#	Purpose: Uses PAPI to get all properties in a group and list hostnames
#	Date: 04/02/2019
#	Version: 1 - Initial
#
#************************************************************************

Param(
    [Parameter(Mandatory=$true)]  [string] $GroupID,
    [Parameter(Mandatory=$false)] [string] $EdgeRCFile = "~\.edgerc",
    [Parameter(Mandatory=$false)] [string] $Section = 'papi',
    [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
)

if(!(Get-Module AkamaiPowershell))
{
    Write-Host -ForegroundColor Yellow "Please import the Akamai Powershell module before running this script"
    return
}

$Results = New-Object -TypeName System.Collections.ArrayList
$Group = Get-Group -GroupID $GroupID -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
$Properties = Get-Properties -GroupID $Group.groupId -ContractId $Group.contractIds[0] -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
Write-Host -ForegroundColor yellow "Found $($Properties.Count) properties"

foreach($Property in $Properties)
{
    $PropHostnames = List-PropertyHostnames -GroupID $Property.groupId -ContractId $Property.contractId -PropertyId $Property.propertyId -PropertyVersion $property.LatestVersion -Section $Section -AccountSwitchKey $AccountSwitchKey
    $PropHostnames | foreach {
        #$Results += @{ "Property" = $Property.propertyName; "Hostname" = $_.cnameFrom}
        $Result = New-Object -TypeName PSObject
        $Result | Add-Member -MemberType NoteProperty -Name "Property" -Value $Property.propertyName
        $Result | Add-Member -MemberType NoteProperty -Name "Hostname" -Value $_.cnameFrom
        $Results.Add($Result) | Out-Null
    }
}

Write-Host -ForegroundColor Yellow "Found $($results.Count) hosts"
return $Results