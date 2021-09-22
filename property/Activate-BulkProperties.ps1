<#
.SYNOPSIS
EdgeGrid Powershell - Property API
.DESCRIPTION
Activate bulk updated properties
.PARAMETER Body
POST body for the request. REQUIRED
.PARAMETER GroupId
Group ID, either with grp_ prefix or not. OPTIONAL
.PARAMETER ContractId
Contract ID, either with ctr_ prefix or not. OPTIONAL
.PARAMETER EdgeRCFile
Path to .edgerc file, defaults to ~/.edgerc. OPTIONAL
.PARAMETER ContractId
.edgerc Section name. Defaults to 'default'. OPTIONAL
.PARAMETER AccountSwitchKey
Account switch key if applying to an account external to yoru API user. Only usable by Akamai staff and partners. OPTIONAL
.EXAMPLE
Activate-BulkProperties -Body <Some JSON Data> -GroupID grp_12345 -ContractID ctr_AB12CD
.LINK
developer.akamai.com
#>

function Activate-BulkProperties
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $GroupId,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/bulk/activations?contractId=$ContractID&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}