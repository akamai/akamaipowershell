function List-CPReportingGroups
{
    Param(
        [Parameter(Mandatory=$false)] [string] $ContractID,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $Name,
        [Parameter(Mandatory=$false)] [string] $CPCodeID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Sanitize IDs
    if($GroupID -and $GroupID.contains("grp_")){ 
        $GroupID = $GroupID.replace("grp_","")
    }
    if($ContractID -and $ContractID.contains("ctr_")){ 
        $ContractID = $ContractID.replace("ctr_","")
    }
    
    $Path = "/cprg/v1/reporting-groups?contractId=$ContractID&groupId=$GroupID&cpcodeId=$CPCodeID&reportingGroupName=$Name"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.groups
    }
    catch {
        throw $_
    }
}
