<#
.SYNOPSIS
EdgeGrid Powershell - Billing API
.DESCRIPTION
List cumulative monthly usage per product, split by contract or reporting group ID
.PARAMETER ContractID
Identifies the contract that you want to see aggregated data from. Either ContractID or ReportingGroupID is REQUIRED
.PARAMETER ReportingGroupID
Identifies the contract that you want to see aggregated data from. Either ContractID or ReportingGroupID is REQUIRED
.PARAMETER ProductID
Identifies the product you want to see aggregated data for. REQUIRED
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
Get-ProductUsagePerMonth -ContractID 1-ABCDEF -ProductID 1-ABC012 -Start 2020-07 -End 2020-09
.LINK
techdocs.akamai.com
#>

function Get-ProductUsagePerMonth
{
    [CmdletBinding(DefaultParameterSetName = 'contract')]
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='contract')]  [string] $ContractID,
        [Parameter(Mandatory=$true,ParameterSetName='reportinggroup')]  [string] $ReportingGroupId,
        [Parameter(Mandatory=$true)]  [string] $ProductID,
        [Parameter(Mandatory=$true)]  [string] $Start,
        [Parameter(Mandatory=$true)]  [string] $End,
        [Parameter(Mandatory=$true,ParameterSetName='contract')]  [switch] $ByCPCode,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($PSCmdlet.ParameterSetName -eq 'contract'){
        $Path = "/billing/v1/contracts/$ContractID/products/$ProductID/usage/monthly-summary?start=$Start&end=$End"

        if($ByCPCode){
            $Path = $Path.replace('monthly-summary','by-cp-code/monthly-summary')
        }
    }
    elseif($PSCmdlet.ParameterSetName -eq 'reportinggroup'){
        $Path = "/billing/v1/reporting-groups/$ReportingGroupID/products/$ProductID/usage/monthly-summary?start=$Start&end=$End"
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
