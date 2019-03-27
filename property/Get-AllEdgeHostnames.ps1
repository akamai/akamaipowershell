function Get-AllEdgeHostnames
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $EdgeHostnames = @()
    if($AccountSwitchKey)
    {
        $Groups = List-Groups -Section $Section -AccountSwitchKey $AccountSwitchKey
    }
    else
    {
        $Groups = List-Groups -Section $Section
    }
    
    foreach($Group in $Groups)
    {
        if($Group.contractIds.length -gt 0)
        {
            if($AccountSwitchKey)
            {
                $EdgeHostnames += List-EdgeHostNames -Section $Section -GroupID $Group.groupID -ContractId $group.ContractIDs[0] -AccountSwitchKey $AccountSwitchKey
            }
            else
            {
                $EdgeHostnames += List-EdgeHostNames -Section $Section -GroupID $Group.groupID -ContractId $group.ContractIDs[0]
            }
        }
    }

    return $EdgeHostnames
}

