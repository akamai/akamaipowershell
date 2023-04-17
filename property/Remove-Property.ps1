function Remove-Property
{
    Param(
        [Parameter(Mandatory=$false,ParameterSetName='name')] [string] $PropertyName,
        [Parameter(Mandatory=$false,ParameterSetName='id')]   [string] $PropertyID,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    if($PropertyName){
        $Property = Find-Property -PropertyName $PropertyName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        $PropertyID = $Property.propertyId
        if($PropertyID -eq ''){
            throw "Property '$PropertyName' not found"
        }
    }

    $Path = "/papi/v1/properties/$PropertyID`?contractId=$ContractId&groupId=$GroupID"

    try {
        $Result = Invoke-AkamaiRestMethod -Method DELETE -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
