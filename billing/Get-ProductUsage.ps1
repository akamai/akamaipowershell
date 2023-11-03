<#
.SYNOPSIS
EdgeGrid Powershell - Billing API
.DESCRIPTION
List usage products per contract
.PARAMETER ContractID
Identifies the contract that you want to see aggregated data from. REQUIRED
.PARAMETER Start
The start (inclusive) of the billable usage period, expressed as an ISO 8601 datestamp (YYYY-MM). REQUIRED
.PARAMETER End
The end (exclusive) of the billable usage period, expressed as an ISO 8601 datestamp (YYYY-MM). REQUIRED
.PARAMETER EdgeRCFile
Path to .edgerc file, defaults to ~/.edgerc. OPTIONAL
.PARAMETER ContractId
.edgerc Section name. Defaults to 'default'. OPTIONAL
.PARAMETER AccountSwitchKey
Account switch key if applying to an account external to yoru API user. Only usable by Akamai staff and partners. OPTIONAL
.EXAMPLE
Get-ProductUsage -ContractID 1-ABCDEF -Start 2020-07 -End 2020-09
.LINK
techdocs.akamai.com
#>

function Get-ProductUsage
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ContractID,
        [Parameter(Mandatory=$true)]  [string] $Start,
        [Parameter(Mandatory=$true)]  [string] $End,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )
    
    $Path = "/billing/v1/contracts/$ContractID/products?start=$Start&end=$End"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
