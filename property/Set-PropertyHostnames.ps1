function Set-PropertyHostnames
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $PropertyId,
        [Parameter(Mandatory=$true)]  [string] $PropertyVersion,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)]  [string[]] $Hostnames,
        [Parameter(ParameterSetName='attributes', Mandatory=$false)]  [string[]] $EdgeHostnames,
        [Parameter(ParameterSetName='postbody', Mandatory=$false)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [switch] $ValidateHostnames,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    # Nullify false switches
    $ValidateHostnamesString = $ValidateHostnames.IsPresent.ToString().ToLower()
    if(!$ValidateHostnames){ $ValidateHostnamesString = '' }

    if($PSCmdlet.ParameterSetName -eq 'attributes')
    {
        $BodyObj = New-Object System.Collections.ArrayList

        # If number of hostnames does not match number of edges, but number of edges is 1 share edge between all
        if($Hostnames.Count -ne 1 -and $EdgeHostnames.Count -eq 1){
            $Hostnames | foreach {
                $BodyObj.Add(
                    @{
                        cnameType = "EDGE_HOSTNAME"
                        cnameFrom = $_
                        cnameTo = $EdgeHostnames[0]
                    }
                ) | Out-Null
            }
        }
        # if numbers do not match and number of edges is not 1, throw an error
        elseif($Hostnames.Count -ne $EdgeHostnames.Count){
            throw "Number of EdgeHostnames should equal number of Hostnames, or be 1 only which is shared"
        }
        # otherwise match hostnames with edges of the same index
        else{
            for($i = 0; $i -lt $Hostnames.Count; $i++ ) {
                $BodyObj.Add(
                    @{
                        cnameType = "EDGE_HOSTNAME"
                        cnameFrom = $Hostnames[$i]
                        cnameTo = $EdgeHostnames[$i]
                    }
                ) | Out-Null
            }
        }

        $Body = $BodyObj | ConvertTo-Json -Depth 100
    }

    $Path = "/papi/v1/properties/$PropertyId/versions/$PropertyVersion/hostnames?contractId=$ContractId&groupId=$GroupID&validateHostnames=$ValidateHostnamesString&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -Body $Body
        return $Result.hostnames.items
    }
    catch {
        throw $_.Exception
    }
}

