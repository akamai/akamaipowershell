function Set-PropertyHostnames
{
    Param(
        [Parameter(ParameterSetName="name", Mandatory=$true)]  [string] $PropertyName,
        [Parameter(ParameterSetName="id", Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$true, ValueFromPipeline)] [array] $PropertyHostnames,
        [Parameter(Mandatory=$false)] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [switch] $ValidateHostnames,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    <#
        Cmdlet broken down into begin, process and end in order to reconstruct pipelined array, which is split out by Powershell into multiple
        single items with the Process section executing for each one.
    #>

    begin{
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
        $CombinedHostnameArray = New-Object -TypeName System.Collections.ArrayList
    }

    process{
        foreach($PropertyHostname in $PropertyHostnames){
            $CombinedHostnameArray.Add($PropertyHostname) | Out-Null
        }
    }

    end{
        $Body = $CombinedHostnameArray | ConvertTo-Json -Depth 100
        Write-Debug "Body = $Body"

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result.hostnames.items
        }
        catch {
            throw $_.Exception
        }
    }
}

