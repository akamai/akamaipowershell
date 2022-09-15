function Remove-PropertyHostnames
{
    Param(
        [Parameter(Mandatory=$false,ParameterSetName='name')] [string] $PropertyName,
        [Parameter(Mandatory=$false,ParameterSetName='id')]   [string] $PropertyID,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$true)]  [string] $HostnamesToRemove,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [switch] $IncludeCertStatus,
        [Parameter(Mandatory=$false)] [switch] $ValidateHostnames,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )


    # nullify false switches
    $IncludeCertStatusString = $IncludeCertStatus.IsPresent.ToString().ToLower()
    if(!$IncludeCertStatus){ $IncludeCertStatusString = '' }
    $ValidateHostnamesString = $ValidateHostnames.IsPresent.ToString().ToLower()
    if(!$ValidateHostnames){ $ValidateHostnamesString = '' }

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

    if($PropertyVersion.ToLower() -eq "latest"){
        try{
            if($PropertyName){
                $PropertyVersion = $Property.propertyVersion
            }
            else{
                $Property = Get-Property -PropertyID $PropertyID -GroupID $GroupID -ContractId $ContractId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
                $PropertyVersion = $Property.latestVersion
            }
        }
        catch{
            throw $_
        }
    }

    $Path = "/papi/v1/properties/$PropertyID/versions/$PropertyVersion/hostnames?contractId=$ContractID&groupId=$GroupID&validateHostnames=$ValidateHostnamesString&includeCertStatus=$IncludeCertStatusString&accountSwitchKey=$AccountSwitchKey"

    $RemovalArray = $HostnamesToRemove -split ","
    $BodyObj = @{ remove = $RemovalArray }
    $Body = $BodyObj | ConvertTo-Json -Depth 100

    try {
        $Result = Invoke-AkamaiRestMethod -Method PATCH -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.hostnames.items
    }
    catch {
        throw $_
    }

}
