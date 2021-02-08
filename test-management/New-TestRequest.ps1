function New-TestRequest
{
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)] [object] $TestRequest,
        [Parameter(Mandatory=$true,ParameterSetName='requestbody')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/test-management/v2/functional/test-requests?accountSwitchKey=$AccountSwitchKey"

        if($TestRequest){
            # Sanitise request body. API does not do this
            $TestRequest.PSObject.Members.Remove('createdBy')
            $TestRequest.PSObject.Members.Remove('createdDate')
            $TestRequest.PSObject.Members.Remove('modifiedBy')
            $TestRequest.PSObject.Members.Remove('modifiedDate')
            $Body = $TestRequest | ConvertTo-Json -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_.Exception 
        }
    }

    end{}

}