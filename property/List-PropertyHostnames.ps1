function List-PropertyHostnames
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $PropertyName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $PropertyID,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [switch] $ValidateHostnames,
        [Parameter(Mandatory=$false)] [switch] $IncludeCertStatus,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Find property if user has specified PropertyName
    if($PropertyName){
        try{
            $Property = Find-Property -PropertyName $PropertyName -latest -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            $PropertyID = $Property.propertyId
            if($PropertyID -eq ''){
                throw "Property '$PropertyName' not found"
            }
        }
        catch{
            throw $_
        }
    }

    # Nullify false switches
    $ValidateHostnamesString = $ValidateHostnames.IsPresent.ToString().ToLower()
    if(!$ValidateHostnames){ $ValidateHostnamesString = '' }
    $IncludeCertStatusString = $IncludeCertStatus.IsPresent.ToString().ToLower()
    if(!$IncludeCertStatus){ $IncludeCertStatusString = '' }

    if($PropertyVersion -eq "latest")
    {
        $PropertyVersion = (Get-Property -PropertyID $PropertyID -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).latestVersion
    }

    $Path = "/papi/v1/properties/$PropertyID/versions/$PropertyVersion/hostnames?contractId=$ContractId&groupId=$GroupID&validateHostnames=$ValidateHostnamesString&includeCertStatus=$IncludeCertStatusString"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.hostnames.items
    }
    catch {
        throw $_
    }
}
