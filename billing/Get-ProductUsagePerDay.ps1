<#
.SYNOPSIS
EdgeGrid Powershell - Billing API
.DESCRIPTION
List cumulative daily usage per product, split by contract or reporting group ID
.PARAMETER ContractID
Identifies the contract that you want to see aggregated data from. Either ContractID or ReportingGroupID is REQUIRED
.PARAMETER ReportingGroupID
Identifies the contract that you want to see aggregated data from. Either ContractID or ReportingGroupID is REQUIRED
.PARAMETER ProductID
Identifies the product you want to see aggregated data for. REQUIRED
.PARAMETER Month
Selected billable usage period, expressed as an ISO 8601 datestamp (YYYY-MM). REQUIRED
.PARAMETER EdgeRCFile
Path to .edgerc file, defaults to ~/.edgerc. OPTIONAL
.PARAMETER ContractId
.edgerc Section name. Defaults to 'default'. OPTIONAL
.PARAMETER AccountSwitchKey
Account switch key if applying to an account external to yoru API user. Only usable by Akamai staff and partners. OPTIONAL
.EXAMPLE
Get-ProductUsagePerDay -ContractID 1-ABCDEF -ProductID 1-ABC012 -Month 2020-07
.LINK
techdocs.akamai.com
#>

function Get-ProductUsagePerDay
{
    [CmdletBinding(DefaultParameterSetName = 'contract')]
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='contract')]  [string] $ContractID,
        [Parameter(Mandatory=$true,ParameterSetName='reportinggroup')]  [string] $ReportingGroupId,
        [Parameter(Mandatory=$true)]  [string] $ProductID,
        [Parameter(Mandatory=$true)]  [string] $Month,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($PSCmdlet.ParameterSetName -eq 'contract'){
        $Path = "/billing/v1/contracts/$ContractID/products/$ProductID/usage/daily?month=$Month&accountSwitchKey=$AccountSwitchKey"
    }
    elseif($PSCmdlet.ParameterSetName -eq 'reportinggroup'){
        $Path = "/billing/v1/reporting-groups/$ReportingGroupID/products/$ProductID/usage/daily?month=$Month&accountSwitchKey=$AccountSwitchKey"
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
