function List-CPReportingGroupWatermarkLimits
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ContractID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Sanitize contract ID
    if($ContractID -and $ContractID.StartsWith("ctr_")){
        $ContractID = $ContractID.Replace("ctr_","")
    }

    $Path = "/cprg/v1/reporting-groups/contracts/$ContractID/watermark-limits"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
