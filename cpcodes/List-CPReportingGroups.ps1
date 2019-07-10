function List-CPReportingGroups
{
    Param(
        [Parameter(Mandatory=$false)] [string] $ContractID,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $Name,
        [Parameter(Mandatory=$false)] [string] $CPCodeID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Sanitize IDs
    if($GroupID -and $GroupID.contains("grp_")){ 
        $GroupID = $GroupID.replace("grp_","")
    }
    if($ContractID -and $ContractID.contains("ctr_")){ 
        $ContractID = $ContractID.replace("ctr_","")
    }
    
    $Path = "/cprg/v1/reporting-groups?contractId=$ContractID&groupId=$GroupID&cpcodeId=$CPCodeID&name=$Name&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.groups
    }
    catch {
        throw $_.Exception
    }
}