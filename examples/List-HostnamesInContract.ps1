#************************************************************************
#
#	Name: List-HostnamesInContract
#	Author: S Macleod
#	Purpose: Uses PAPI to get all properties in contract and list hostnames
#	Date: 04/02/2019
#	Version: 1 - Initial
#
#************************************************************************

Param(
    [Parameter(Mandatory=$false)] [string] $AccountSwitchKey,
    [Parameter(Mandatory=$false)] [string] $EdgeRCFile = "~\.edgerc",
    [Parameter(Mandatory=$false)] [string] $Section = 'papi'
)

if(!(Get-Module AkamaiPowershell))
{
    Write-Host -ForegroundColor Yellow "Please import the Akamai Powershell module before running this script"
    return
}

$Results = @()
$Properties = Get-AllProperties -Section $Section -AccountSwitchKey $AccountSwitchKey
Write-Host -ForegroundColor yellow "Found $($Properties.Count) properties"

foreach($Property in $Properties)
{
    $PropHostnames = List-PropertyHostnames -GroupID $Property.groupId -ContractId $Property.contractId -PropertyId $Property.propertyId -PropertyVersion $Property.LatestVersion -Section $Section -AccountSwitchKey $AccountSwitchKey
    $PropHostnames | foreach {
        #$Results += @{ "Property" = $Property.propertyName; "Hostname" = $_.cnameFrom}
        $Result = New-Object -TypeName PSObject
        $Result | Add-Member -MemberType NoteProperty -Name "Property" -Value $Property.propertyName
        $Result | Add-Member -MemberType NoteProperty -Name "Hostname" -Value $_.cnameFrom
        $Results += $Result
    }
}

Write-Host -ForegroundColor Yellow "Found $($results.Count) hosts"
return $Results