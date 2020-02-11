function Get-Group
{
    Param(
        [Parameter(Mandatory=$true, ParameterSetName="id")] [string] $GroupID,
        [Parameter(Mandatory=$true, ParameterSetName="name")] [string] $GroupName,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    try {
        $groups = Get-Groups -AccountSwitchKey $AccountSwitchKey -EdgeRCFile $EdgeRCFile -Section $Section
        if($GroupID){
            return $Groups | Where {$_.groupId -eq $GroupID}
        }
        else{
            return $Groups | Where {$_.groupName -eq $GroupName}
        }
    }
    catch {
        throw $_.Exception
    }           
}