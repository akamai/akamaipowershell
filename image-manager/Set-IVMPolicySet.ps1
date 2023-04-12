function Set-IVMPolicySet {
    Param(
        [Parameter(Mandatory = $true)]  [string] $PolicySetID,
        [Parameter(Mandatory = $false)] [string] $Name,
        [Parameter(Mandatory = $false)] [string] [ValidateSet('US', 'EMEA', 'ASIA', 'AUSTRALIA', 'JAPAN', 'CHINA')] $Region,
        [Parameter(Mandatory = $false)] [string] $ContractID,
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey
    )

    $Path = "/imaging/v2/policysets/$PolicySetID"

    if ($ContractID -ne '') {
        $AdditionalHeaders['Contract'] = $ContractID
    }

    $BodyObj = @{}
    if ($Name) { $BodyObj.name = $Name }
    if ($Region) { $BodyObj.region = $Region }
    $Body = ConvertTo-Json $BodyObj

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}