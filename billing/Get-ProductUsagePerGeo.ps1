<#
.SYNOPSIS
EdgeGrid Powershell - Billing API
.DESCRIPTION
Provides details on subcustomer invoicing for each geographic zone within the Akamai network for Akamai Cloud Embed
.PARAMETER ContractID
Identifies the contract that you want to see aggregated data from. REQUIRED
.PARAMETER ProductID
Identifies the product you want to see aggregated data for. REQUIRED
.PARAMETER Day
The day for which you want to see aggregated data. You need to specify corresponding month and year values. REQUIRED
.PARAMETER Month
The month for which you want to see aggregated data. You need to specify corresponding year and day values. REQUIRED
.PARAMETER Year
The year for which you want to see aggregated data. You need to specify corresponding month and day values. REQUIRED
.PARAMETER EdgeRCFile
Path to .edgerc file, defaults to ~/.edgerc. OPTIONAL
.PARAMETER ContractId
.edgerc Section name. Defaults to 'default'. OPTIONAL
.PARAMETER AccountSwitchKey
Account switch key if applying to an account external to yoru API user. Only usable by Akamai staff and partners. OPTIONAL
.EXAMPLE
Get-ProductUsagePerGeo -ContractID 1-ABCDEF -ProductID 1-ABC012 -Day 1 -Month 1 -Year 2022
.LINK
techdocs.akamai.com
#>

function Get-ProductUsagePerGeo
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ContractID,
        [Parameter(Mandatory=$true)]  [string] $ProductID,
        [Parameter(Mandatory=$true)]  [int] $Day,
        [Parameter(Mandatory=$true)]  [int] $Month,
        [Parameter(Mandatory=$true)]  [int] $Year,
        [Parameter(Mandatory=$false)] [string] $OutputFilename = 'usage.gz',
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )
    
    $Path = "/billing/v1/contracts/$ContractID/products/$ProductID/geo-billing-files?day=$Day&month=$Month&year=$Year&accountSwitchKey=$AccountSwitchKey"

    $AdditionalHeaders = @{
        Accept = "*/*"
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
