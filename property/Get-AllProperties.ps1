function Get-AllProperties
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Properties = @()
    $Groups = List-Groups -Section $Section -AccountSwitchKey $AccountSwitchKey    
    if($PSCmdlet.MyInvocation.BoundParameters["Verbose"] -eq $true)
    {
        Write-Host "Found $($Groups.Count) groups"
    }
    
    foreach($Group in $Groups)
    {
        if($Group.contractIds.length -gt 0)
        {
            try {
                $Properties += List-Properties -Section $Section -GroupID $Group.groupID -ContractId $group.ContractIDs[0] -AccountSwitchKey $AccountSwitchKey
            }
            catch {
                if($PSCmdlet.MyInvocation.BoundParameters["Verbose"] -eq $true)
                {
                    Write-Host "Warning: Could not retrieve properties for group $($Group.groupName)"
                }
            }
        }
    }

    return $Properties
}

