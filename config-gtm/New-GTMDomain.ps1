function New-GTMDomain
{
    Param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true,ParameterSetName='object')] [object] $Domain,
        [Parameter(Mandatory=$false, ParameterSetName='body')] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $ContractID,
        [Parameter(Mandatory=$false)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/config-gtm/v1/domains/?contractId=$ContractID&gid=$GroupID&accountSwitchKey=$AccountSwitchKey"

        if($Domain){
            $Body = $Domain | ConvertTo-Json -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method POST -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_
        }  
    }

    end{}

}
