function Add-PropertyHostnames
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$true)]  [string[]] $NewHostnames,
        [Parameter(Mandatory=$true)]  [string[]] $Edgekeynames,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [switch] $ValidateHostnames,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Check creds
    $Credentials = Get-AKCredentialsFromRC -EdgeRCFile $EdgeRCFile -Section $Section
    if(!$Credentials){ return $null }

    # Input validation
    if($NewHostnames.Count -eq 1 -and $NewHostnames[0].Contains(","))
    {
        $NewHostnames = $NewHostnames[0].Replace(" ", "").Split(",")
    }
    if($Edgekeynames.Count -eq 1 -and $Edgekeynames[0].Contains(","))
    {
        $Edgekeynames = $Edgekeynames[0].Replace(" ", "").Split(",")
    }

    $CurrentHostnames = Get-PropertyHostnames -PropertyId $PropertyId -PropertyVersion $PropertyVersion -GroupID $GroupID -ContractId $ContractId -Section $Section -AccountSwitchKey $AccountSwitchKey
    $CurrentHostnames = [System.Collections.ArrayList] $CurrentHostnames

    for($i = 0; $i -lt $NewHostnames.Count; $i++)
    {
        if($NewHostnames.Count -eq $Edgekeynames.Count)
        {
            $RelativeEdge = $Edgekeynames[$i]
        }
        else
        {
            $RelativeEdge = $Edgekeynames[0]
        }

        $CurrentHostnames.Add( [PSCustomObject] @{
            cnameType = "EDGE_HOSTNAME";
            cnameFrom = $NewHostnames[$i];
            cnameTo = $RelativeEdge
        }) | Out-Null
    }

    $Body = $CurrentHostnames | ConvertTo-Json -Depth 100

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

