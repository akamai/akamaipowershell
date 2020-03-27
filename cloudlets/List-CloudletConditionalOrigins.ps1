function List-CloudletConditionalOrigins
{
    Param(
        [Parameter(Mandatory=$false)] [string] [ValidateSet('APPLICATION_LOAD_BALANCER','CUSTOMER','NETSTORAGE')] $Type = 'APPLICATION_LOAD_BALANCER',
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'cloudlets',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )
    
    $Path = "/cloudlets/api/v2/origins?type=$Type&accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_.Exception
    }
}