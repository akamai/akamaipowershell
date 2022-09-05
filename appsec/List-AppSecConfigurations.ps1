function List-AppSecConfigurations
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $IncludeContractAndGroup,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # nullify false switches
    $IncludeContractAndGroupString = $IncludeContractAndGroup.IsPresent.ToString().ToLower()
    if(!$IncludeContractAndGroup){ $IncludeContractAndGroupString = '' }

    $Path = "/appsec/v1/configs?includeContractGroup=$IncludeContractAndGroupString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.configurations
    }
    catch {
        throw $_ 
    }
}