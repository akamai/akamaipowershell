function List-Groups
{
    Param(
        [Parameter(Mandatory=$false)] [switch] $Detail,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/groups"

    try {
        $groups = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
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
