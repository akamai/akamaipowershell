function Get-BucketActivation {
    Param(
        [Parameter(ParameterSetName = "name", Mandatory = $true)]  [string] $PropertyName,
        [Parameter(ParameterSetName = "id", Mandatory = $true)]  [string] $PropertyID,
        [Parameter(Mandatory = $true)]  [string] $ActivationID,
        [Parameter(Mandatory = $false)] [switch] $IncludeHostnames,
        [Parameter(Mandatory = $false)] [string] $GroupID,
        [Parameter(Mandatory = $false)] [string] $ContractId,
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey
    )

    # Nullify false switches
    $IncludeHostnamesString = $IncludeHostnames.IsPresent.ToString().ToLower()
    if (!$IncludeHostnames) { $IncludeHostnamesString = '' }

    # Find property if user has specified PropertyName
    if ($PropertyName) {
        try {
            $Property = Find-Property -PropertyName $PropertyName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            $PropertyID = $Property.propertyId
            if ($PropertyID -eq '') {
                throw "Property '$PropertyName' not found"
            }
        }
        catch {
            throw $_
        }
    }

    $Path = "/papi/v1/properties/$PropertyID/hostname-activations/$ActivationID`?includeHostnames=$IncludeHostnamesString&contractId=$ContractId&groupId=$GroupID&offset=$OffSet&limit=$Limit"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.hostnameActivations.items
    }
    catch {
        throw $_
    }
}