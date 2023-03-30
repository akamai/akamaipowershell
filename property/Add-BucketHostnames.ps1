function Add-BucketHostnames {
    Param(
        [Parameter(Mandatory = $false, ParameterSetName = 'name')] [string]   $PropertyName,
        [Parameter(Mandatory = $false, ParameterSetName = 'id')]   [string]   $PropertyID,
        [Parameter(Mandatory = $true)]  [string] [ValidateSet('STAGING', 'PRODUCTION')] $Network,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]  [object[]] $NewHostnames,
        [Parameter(Mandatory = $false)] [string] $GroupID,
        [Parameter(Mandatory = $false)] [string] $ContractId,
        [Parameter(Mandatory = $false)] [switch] $IncludeCertStatus,
        [Parameter(Mandatory = $false)] [switch] $ValidateHostnames,
        [Parameter(Mandatory = $false)] [string] $EdgeRCFile,
        [Parameter(Mandatory = $false)] [string] $Section,
        [Parameter(Mandatory = $false)] [string] $AccountSwitchKey
    )

    <#
        Cmdlet broken down into begin, process and end in order to reconstruct pipelined array, which is split out by Powershell into multiple
        single items with the Process section executing for each one.
    #>

    begin {
        # nullify false switches
        $IncludeCertStatusString = $IncludeCertStatus.IsPresent.ToString().ToLower()
        if (!$IncludeCertStatus) { $IncludeCertStatusString = '' }
        $ValidateHostnamesString = $ValidateHostnames.IsPresent.ToString().ToLower()
        if (!$ValidateHostnames) { $ValidateHostnamesString = '' }

        # Capitalise $Network, API seems to care
        $Network = $Network.ToUpper()

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

        $Path = "/papi/v1/properties/$PropertyID/hostnames?contractId=$ContractID&groupId=$GroupID&network=$Network&validateHostnames=$ValidateHostnamesString&includeCertStatus=$IncludeCertStatusString"
        $CombinedHostnameArray = New-Object -TypeName System.Collections.ArrayList
    }

    process {
        foreach ($Hostname in $NewHostnames) {
            $CombinedHostnameArray.Add($Hostname) | Out-Null
        }
    }

    end {
        $BodyObj = @{
            network = $Network
            add     = $CombinedHostnameArray 
        }
        $Body = $BodyObj | ConvertTo-Json -Depth 100

        try {
            $Result = Invoke-AkamaiRestMethod -Method PATCH -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            return $Result.hostnames
        }
        catch {
            throw $_
        }
    }
}