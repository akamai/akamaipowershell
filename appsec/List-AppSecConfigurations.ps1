function List-AppSecConfigurations
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $IncludeContractAndGroup,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $IncludeContractAndGroupString = $IncludeContractAndGroup.IsPresent.ToString().ToLower()
    if(!$IncludeContractAndGroup){ $IncludeContractAndGroupString = '' }

    $Path = "/appsec/v1/configs?includeContractGroup=$IncludeContractAndGroupString"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.configurations
    }
    catch {
        throw $_ 
    }
}
