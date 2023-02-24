function New-TestRequests
{
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)] [object[]] $TestRequests,
        [Parameter(Mandatory=$true,ParameterSetName='requestbody')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{
        $Path = "/test-management/v2/functional/test-requests"
        if($PSCmdlet.ParameterSetName -eq 'pipeline'){
            $CombinedRequestsArray = New-Object -TypeName System.Collections.ArrayList
        }
    }

    process{
        if($PSCmdlet.ParameterSetName -eq 'pipeline'){
            foreach($TestRequest in $TestRequests){
                # Sanitise request body. API does not do this
                $TestRequest.PSObject.Members.Remove('createdBy')
                $TestRequest.PSObject.Members.Remove('createdDate')
                $TestRequest.PSObject.Members.Remove('modifiedBy')
                $TestRequest.PSObject.Members.Remove('modifiedDate')
                $CombinedRequestsArray.Add($TestRequest) | Out-Null
            }
        }
    }

    end{
        if($PSCmdlet.ParameterSetName -eq 'pipeline'){
            $Body = $CombinedRequestsArray | ConvertTo-Json -Depth 100 -AsArray
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            return $Result
        }
        catch {
            throw $_ 
        }
    }

}
