function Set-GTMDomainDatacenter
{
    Param(
        [Parameter(Mandatory=$true)] [string] $DomainName,
        [Parameter(Mandatory=$true)] [string] $DatacenterID,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='pipeline')] [object] $Datacenter,
        [Parameter(Mandatory=$true,ParameterSetName='postbody')] [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    begin{}

    process{
        $Path = "/config-gtm/v1/domains/$DomainName/datacenters/$DatacenterID`?accountSwitchKey=$AccountSwitchKey"

        if($Datacenter){
            $Body = $Datacenter | ConvertTo-Json -Depth 100
        }

        try {
            $Result = Invoke-AkamaiRestMethod -Method PUT -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
            return $Result
        }
        catch {
            throw $_.Exception
        }
    }

    end{}  
}