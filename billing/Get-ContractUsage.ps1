function Get-ContractUsage
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ContractID,
        [Parameter(Mandatory=$true)]  [string] $ProductID,
        [Parameter(Mandatory=$true,ParameterSetName='fromto')] [string] $FromMonth,
        [Parameter(Mandatory=$true,ParameterSetName='fromto')] [string] $FromYear,
        [Parameter(Mandatory=$true,ParameterSetName='fromto')] [string] $ToMonth,
        [Parameter(Mandatory=$true,ParameterSetName='fromto')] [string] $ToYear,
        [Parameter(Mandatory=$true,ParameterSetName='monthyear')] [string] $Month,
        [Parameter(Mandatory=$true,ParameterSetName='monthyear')] [string] $Year,
        [Parameter(Mandatory=$false)] [string] $StatisticName,
        [Parameter(Mandatory=$false)] [switch] $BillingDayOnly,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $BillingDayOnlyString = $BillingDayOnly.IsPresent.ToString().ToLower()
    if(!$BillingDayOnly){ $BillingDayOnlyString = '' }

    $Path = "/billing-center-api/v2/contracts/$ContractID/products/$ProductID/measures?fromMonth=$FromMonth&fromYear=$FromYear&toMonth=$ToMonth&toYear=$ToYear&month=$Month&year=$Year&statisticName=$StatisticName&billingDayOnly=$BillingDayOnlyString&accountSwitchKey=$AccountSwitchKey"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}