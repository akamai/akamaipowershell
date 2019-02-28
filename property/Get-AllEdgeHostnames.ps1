function Get-AllEdgeHostnames
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $EdgeHostnames = @()
    if($AccountSwitchKey)
    {
        $Groups = Get-Groups -Section $Section -AccountSwitchKey $AccountSwitchKey
    }
    else
    {
        $Groups = Get-Groups -Section $Section
    }
    
    foreach($Group in $Groups)
    {
        if($Group.contractIds.length -gt 0)
        {
            if($AccountSwitchKey)
            {
                $EdgeHostnames += Get-EdgeHostNames -Section $Section -GroupID $Group.groupID -ContractId $group.ContractIDs[0] -AccountSwitchKey $AccountSwitchKey
            }
            else
            {
                $EdgeHostnames += Get-EdgeHostNames -Section $Section -GroupID $Group.groupID -ContractId $group.ContractIDs[0]
            }
        }
    }

    return $EdgeHostnames
}

