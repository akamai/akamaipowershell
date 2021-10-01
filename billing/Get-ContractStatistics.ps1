function Get-ContractStatistics
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
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/billing-center-api/v2/contracts/$ContractID/products/$ProductID/statistics?fromMonth=$FromMonth&fromYear=$FromYear&toMonth=$ToMonth&toYear=$ToYear&month=$Month&year=$Year&accountSwitchKey=$AccountSwitchKey"
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}