function Get-Group
{
    Param(
        [Parameter(Mandatory=$true)] [string] $GroupID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    try {
        $groups = Get-Groups -AccountSwitchKey $AccountSwitchKey -EdgeRCFile $EdgeRCFile -Section $Section
        return $Groups | Where {$_.groupId -eq $GroupID}
    }
    catch {
        throw $_.Exception
    }           
}