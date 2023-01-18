function List-Groups
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $Detail,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/groups?accountSwitchKey=$AccountSwitchKey"

    try {
        $groups = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        $returnGroup = $groups.groups.items

        if($Detail)
        {
            $returnGroup = $groups
        }
        
        return $returnGroup 
    }
    catch {
        throw $_
    }           
}
