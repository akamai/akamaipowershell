function New-BulkVersion
{
    Param(
        [Parameter(Mandatory=$true,ParameterSetName='pipeline',ValueFromPipeline=$true)]  [object] $Versions,
        [Parameter(Mandatory=$true,ParameterSetName='postbody')]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $GroupId,
        [Parameter(Mandatory=$false)] [string] $ContractId,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/papi/v1/bulk/property-version-creations?contractId=$ContractID&groupId=$GroupID&accountSwitchKey=$AccountSwitchKey"
        
        if($Versions){
            $Body = $Versions | ConvertTo-Json -depth 100
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