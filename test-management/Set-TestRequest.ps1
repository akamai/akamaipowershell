function Set-TestRequest
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $TestRequestID,
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)] [object] $TestRequest,
        [Parameter(Mandatory=$true,ParameterSetName='requestbody')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/test-management/v2/functional/test-requests/$TestRequestID"

        if($TestRequest){
            # Sanitise request body. API does not do this
            $TestRequest.PSObject.Members.Remove('createdBy')
            $TestRequest.PSObject.Members.Remove('createdDate')
            $TestRequest.PSObject.Members.Remove('modifiedBy')
            $TestRequest.PSObject.Members.Remove('modifiedDate')
            $Body = $TestRequest | ConvertTo-Json -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
            return $Result
        }
        catch {
            throw $_ 
        }
    }

    end{}

}
