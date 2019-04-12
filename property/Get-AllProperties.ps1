function Get-AllProperties
{
    Param(
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Properties = New-Object System.Collections.ArrayList
    $Groups = List-Groups -Section $Section -AccountSwitchKey $AccountSwitchKey    
    if($PSCmdlet.MyInvocation.BoundParameters["Verbose"] -eq $true)
    {
        Write-Host "Found $($Groups.Count) groups"
    }
    
    for($i = 0; $i -lt $Groups.Count; $i++)
    {
        $PercentComplete = ($i / $Groups.Count * 100)
        $PercentComplete = [math]::Round($PercentComplete)
        Write-Progress -Activity "Listing properties..." -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete;
    
        $Group = $Groups[$i]
        if($Group.contractIds.length -gt 0)
        {
            try {
                $PropertiesToAdd = List-Properties -Section $Section -GroupID $Group.groupID -ContractId $group.ContractIDs[0] -AccountSwitchKey $AccountSwitchKey
                if($PropertiesToAdd.Count -gt 1)
                {
                    $Properties.AddRange($PropertiesToAdd) | Out-Null
                }
                elseif($PropertiesToAdd.Count -eq 1) {
                    $Properties.Add($PropertiesToAdd) | Out-Null
                }
                else {
                    continue
                }
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

