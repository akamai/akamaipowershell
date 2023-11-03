function Get-GroupByName
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $GroupName,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/groups"
    
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.groups.items | where {$_.groupName -eq $GroupName} 
    }
    catch {
        throw $_
    }
}
