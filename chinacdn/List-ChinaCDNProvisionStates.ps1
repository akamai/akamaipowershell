function List-ChinaCDNProvisionStates
{
    Param(
        [Parameter(Mandatory=$false)] [string] $ProvisionState,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/chinacdn/v1/current-provision-states?provisionState=$ProvisionState&accountSwitchKey=$AccountSwitchKey"

    $AdditionalHeaders = @{
        Accept = 'application/vnd.akamai.chinacdn.provision-states.v1+json'
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -AdditionalHeaders $AdditionalHeaders -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.provisionStates
    }
    catch {
        throw $_.Exception 
    }
}