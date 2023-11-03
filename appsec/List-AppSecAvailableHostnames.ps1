function List-AppSecAvailableHostnames
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupId,
        [Parameter(Mandatory=$true)]  [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/appsec/v1/contracts/$ContractId/groups/$GroupId/selectable-hostnames"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.availableSet
    }
    catch {
        throw $_ 
    }
}
