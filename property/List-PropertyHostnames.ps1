function List-PropertyHostnames
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [switch] $ValidateHostnames,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Nullify false switches
    $ValidateHostnamesString = $ValidateHostnames.IsPresent.ToString().ToLower()
    if(!$ValidateHostnames){ $ValidateHostnamesString = '' }

    if($PropertyVersion -eq "latest")
    {
        $PropertyVersion = (Get-Property -PropertyId $PropertyId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).latestVersion
    }

    $Path = "/papi/v1/properties/$PropertyId/versions/$PropertyVersion/hostnames?contractId=$ContractId&groupId=$GroupID&validateHostnames=$ValidateHostnamesString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.hostnames.items
    }
    catch {
        throw $_.Exception
    }
}

