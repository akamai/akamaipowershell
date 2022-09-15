function Add-PropertyHostnames
{
    Param(
        [Parameter(Mandatory=$false,ParameterSetName='name')] [string]   $PropertyName,
        [Parameter(Mandatory=$false,ParameterSetName='id')]   [string]   $PropertyID,
        [Parameter(Mandatory=$true)]  [string]   $PropertyVersion,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]  [object[]] $NewHostnames,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [switch] $IncludeCertStatus,
        [Parameter(Mandatory=$false)] [switch] $ValidateHostnames,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    <#
        Cmdlet broken down into begin, process and end in order to reconstruct pipelined array, which is split out by Powershell into multiple
        single items with the Process section executing for each one.
    #>

    begin{
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
        $CombinedHostnameArray = New-Object -TypeName System.Collections.ArrayList
    }

    process{
        foreach($Hostname in $NewHostnames){
            $CombinedHostnameArray.Add($Hostname) | Out-Null
        }
    }

    end{
        $BodyObj = @{ add = $CombinedHostnameArray }
        $Body = $BodyObj | ConvertTo-Json -Depth 100

        try {
            $Result = Invoke-AkamaiRestMethod -Method PATCH -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result.hostnames.items
        }
        catch {
            throw $_
        }
    }

    
}


