function Set-PropertyHostnames
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $PropertyName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$false, ValueFromPipeline)] [System.Object] $PropertyHostnames,
        [Parameter(Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [switch] $ValidateHostnames,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    process{
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
                throw $_.Exception
            }
        }

        if($PropertyVersion -eq "latest")
        {
            $PropertyVersion = (Get-Property -PropertyId $PropertyId -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey).latestVersion
        }

        # Nullify false switches
        $ValidateHostnamesString = $ValidateHostnames.IsPresent.ToString().ToLower()
        if(!$ValidateHostnames){ $ValidateHostnamesString = '' }

        $Path = "/papi/v1/properties/$PropertyId/versions/$PropertyVersion/hostnames?contractId=$ContractId&groupId=$GroupID&validateHostnames=$ValidateHostnamesString&accountSwitchKey=$AccountSwitchKey"

        if($PropertyHostnames){
            $Body = $PropertyHostnames | ConvertTo-Json -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
            return $Result.hostnames.items
        }
        catch {
            throw $_.Exception
        }
    }
}

