function Remove-PropertyHostnames
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$true)]  [string[]] $HostnamesToRemove,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [switch] $ValidateHostnames,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -Section $Section
    if(!$Credentials){ return $null }

    # Input validation
    if($HostnamesToRemove.Count -eq 1 -and $HostnamesToRemove[0].Contains(","))
    {
        $HostnamesToRemove = $HostnamesToRemove[0].Replace(" ", "").Split(",")
    }

    $CurrentHostnames = Get-PropertyHostnames -PropertyId $PropertyId -PropertyVersion $PropertyVersion -GroupID $GroupID -ContractId $ContractId -Section $Section -AccountSwitchKey $AccountSwitchKey
    $RemainingHostnames = New-Object System.Collections.ArrayList

    $CurrentHostnames | foreach {
        if($_.cnameFrom -notin $HostnamesToRemove)
        {
            $RemainingHostnames.Add($_) | Out-Null
        }
    }

    $Body = $RemainingHostnames | ConvertTo-Json -Depth 100

    try {
        if($ValidateHostnames)
        {
            $Result = Update-PropertyHostnames -PropertyId $PropertyId -PropertyVersion $PropertyVersion -Body $Body -GroupID $GroupID -ContractId $ContractId -ValidateHostnames -Section $Section -AccountSwitchKey $AccountSwitchKey
        }
        else
        {
            $Result = Update-PropertyHostnames -PropertyId $PropertyId -PropertyVersion $PropertyVersion -Body $Body -GroupID $GroupID -ContractId $ContractId -Section $Section -AccountSwitchKey $AccountSwitchKey
        }
       
        return $Result
    }
    catch {
        throw $_.Exception
    }
}

