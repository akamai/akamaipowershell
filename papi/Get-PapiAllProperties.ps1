function Get-PapiAllProperties
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Properties = @()
    if($AccountSwitchKey)
    {
        $Groups = Get-PapiGroups -Section $Section -AccountSwitchKey $AccountSwitchKey
    }
    else
    {
        $Groups = Get-PapiGroups -Section $Section
    }
    
    foreach($Group in $Groups)
    {
        if($Group.contractIds.length -gt 0)
        {
            if($AccountSwitchKey)
            {
                $Properties += Get-PapiProperties -Section $Section -GroupID $Group.groupID -ContractId $group.ContractIDs[0] -AccountSwitchKey $AccountSwitchKey
            }
            else
            {
                $Properties += Get-PapiProperties -Section $Section -GroupID $Group.groupID -ContractId $group.ContractIDs[0]
            }
        }
    }

    return $Properties
}

