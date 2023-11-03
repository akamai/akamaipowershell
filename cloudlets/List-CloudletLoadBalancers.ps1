function List-CloudletLoadBalancers
{
    Param(
        [Parameter(Mandatory=$false)] [string] [ValidateSet('APPLICATION_LOAD_BALANCER','CUSTOMER','NETSTORAGE')] $Type = 'APPLICATION_LOAD_BALANCER',
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )
    
    $Path = "/cloudlets/api/v2/origins?type=$Type"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result
    }
    catch {
        throw $_
    }
}
