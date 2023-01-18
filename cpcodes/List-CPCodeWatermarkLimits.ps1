function List-CPCodeWatermarkLimits
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $ContractID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Sanitize contract ID
    if($ContractID -and $ContractID.StartsWith("ctr_")){
        $ContractID = $ContractID.Replace("ctr_","")
    }

    $Path = "/cprg/v1/cpcodes/contracts/$ContractID/watermark-limits?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
