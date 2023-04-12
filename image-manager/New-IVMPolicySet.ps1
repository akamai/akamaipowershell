function New-IVMPolicySet {
    Param(
        [Parameter(Mandatory = $true, ParameterSetName = 'attributes')] [string] $Name,
        [Parameter(Mandatory = $true, ParameterSetName = 'attributes')] [string] [ValidateSet('US', 'EMEA', 'ASIA', 'AUSTRALIA', 'JAPAN', 'CHINA')] $Region,
        [Parameter(Mandatory = $true, ParameterSetName = 'attributes')] [string] [ValidateSet('IMAGE', 'VIDEO')]$Type,
        [Parameter(Mandatory = $false, ParameterSetName = 'attributes')] [Object] $DefaultPolicy,
        [Parameter(Mandatory = $false, ParameterSetName = 'body')] [string] $Body,
        [Parameter(Mandatory = $false)] [string] $ContractID,
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey
    )

    $Path = "/imaging/v2/policysets"

    if ($ContractID -ne '') {
        $AdditionalHeaders['Contract'] = $ContractID
    }

    if ($PSCmdlet.ParameterSetName -eq 'attributes') {
        $BodyObj = @{
            name   = $Name
            region = $Region
            type   = $Type
        }
        if ($DefaultPolicy) {
            $BodyObj.defaultPolicy = $DefaultPolicy
        }

        $Body = ConvertTo-Json $BodyObj
    }

    try {
        $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}