function New-CPCode
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $CPCodeName,
        [Parameter(Mandatory=$true)]  [string] $ProductID,
        [Parameter(Mandatory=$true)]  [string] $ContractID,
        [Parameter(Mandatory=$true)]  [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $PostObj = @{"productId" = $ProductID; "cpcodeName" = $CPCodeName}
    $Body = $PostObj | ConvertTo-Json -Dept 10

    $Path = "/papi/v1/cpcodes?contractId=$ContractID&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"

    $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
    return $Result
}