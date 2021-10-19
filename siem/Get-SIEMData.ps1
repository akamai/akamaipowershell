<#
.SYNOPSIS
EdgeGrid Powershell - SIEM API
.DESCRIPTION
Collect SIEM data
.PARAMETER ConfigID
Configuration ID of AppSec config. REQUIRED
.PARAMETER Offset
Fetches only security events that have occurred from offset
.PARAMETER Limit
Maximum number of events to fetch
.PARAMETER From
The start of a specified time range, expressed in Unix epoch seconds. OPTIONAL
.PARAMETER To
The end of a specified time range, expressed in Unix epoch seconds. OPTIONAL
.PARAMETER EdgeRCFile
Path to .edgerc file, defaults to ~/.edgerc. OPTIONAL
.PARAMETER ContractId
.edgerc Section name. Defaults to 'default'. OPTIONAL
.PARAMETER AccountSwitchKey
Account switch key if applying to an account external to yoru API user. Only usable by Akamai staff and partners. OPTIONAL
.EXAMPLE
Get-SIEMData -ConfigID 12345 -From 1634553896 -To 1634553996
.LINK
developer.akamai.com
#>

function Get-SIEMData
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ConfigID,
        [Parameter(Mandatory=$false)] [string] $Offset,
        [Parameter(Mandatory=$false)] [string] $Limit,
        [Parameter(Mandatory=$false)] [string] $From,
        [Parameter(Mandatory=$false)] [string] $To,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/siem/v1/configs/$ConfigID`?offset=$Offset&limit=$Limit&from=$From&to=$To&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception 
    }
}