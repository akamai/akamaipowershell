function Set-PropertyHostnames
{
    Param(
        [Parameter(Mandatory=$false)]  [string] $PropertyName,
        [Parameter(Mandatory=$false)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)] [array] $PropertyHostnames,
        [Parameter(Mandatory=$true,ParameterSetName='postbody')] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
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
        if($PropertyName -eq '' -and $PropertyID -eq ''){
            throw 'You must provide either $PropertyName or $PropertyID'
        }
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
        if($PSCmdlet.ParameterSetName -eq 'pipeline'){
            $CombinedHostnameArray = New-Object -TypeName System.Collections.ArrayList
        }
    }

    process{
        if($PSCmdlet.ParameterSetName -eq 'pipeline'){
            foreach($PropertyHostname in $PropertyHostnames){
                $CombinedHostnameArray.Add($PropertyHostname) | Out-Null
            }
        }
    }

    end{
        if($PSCmdlet.ParameterSetName -eq 'pipeline'){
            $Body = $CombinedHostnameArray | ConvertTo-Json -Depth 100 -AsArray
        }
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

