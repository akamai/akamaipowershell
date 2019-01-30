function Get-PapiAllProperties
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'papi'
    )

    $Properties = @()
    $Groups = Get-PapiGroups -Section $Section
    foreach($Group in $Groups)
    {
        if($Group.contractIds.length -gt 0)
        {
            $Properties += Get-PapiProperties -Section $Section -GroupID $Group.groupID -ContractId $group.ContractIDs[0]
        }
    }

    return $Properties
}

