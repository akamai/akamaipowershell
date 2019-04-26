function Get-AllEdgeHostnames
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $EdgeHostnames = New-Object System.Collections.ArrayList
    $Groups = List-Groups -Section $Section -AccountSwitchKey $AccountSwitchKey
    
    for($i = 0; $i -lt $Groups.Count; $i++)
    {
        $PercentComplete = ($i / $Groups.Count * 100)
        $PercentComplete = [math]::Round($PercentComplete)
        Write-Progress -Activity "Listing properties..." -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete;
    
        $Group = $Groups[$i]
        if($Group.contractIds.length -gt 0)
        {
            $GroupEdges = List-EdgeHostNames -Section $Section -GroupID $Group.groupID -ContractId $group.ContractIDs[0] -AccountSwitchKey $AccountSwitchKey
            if($GroupEdges.Count -eq 1){ $EdgeHostnames.Add($GroupEdges) | Out-Null }
            elseif($GroupEdges.Count -gt 1){ $EdgeHostnames.AddRange($GroupEdges) | Out-Null }
        }
    }

    return $EdgeHostnames
}

