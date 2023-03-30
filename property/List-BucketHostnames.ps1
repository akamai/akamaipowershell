function List-BucketHostnames
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $PropertyName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $PropertyID,
        [Parameter(Mandatory=$true)]  [string] [ValidateSet('STAGING','PRODUCTION')] $Network,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $OffSet,
        [Parameter(Mandatory=$false)] [string] $Limit,
        [Parameter(Mandatory=$false)] [string] $Sort,
        [Parameter(Mandatory=$false)] [string] $HostnameFilter,
        [Parameter(Mandatory=$false)] [string] $CNAMEToFilter,
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
    $IncludeCertStatusString = $IncludeCertStatus.IsPresent.ToString().ToLower()
    if(!$IncludeCertStatus){ $IncludeCertStatusString = '' }

    # Capitalise $Network, API seems to care
    $Network = $Network.ToUpper()

    $Path = "/papi/v1/properties/$PropertyID/hostnames?contractId=$ContractId&groupId=$GroupID&network=$Network&offset=$OffSet&limit=$Limit&sort=$Sort&hostname=$HostnameFilter&cnameTo=$CNAMEToFilter&includeCertStatus=$IncludeCertStatusString"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.hostnames.items
    }
    catch {
        throw $_
    }
}