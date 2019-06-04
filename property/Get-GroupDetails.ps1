function Get-GroupDetails
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Group,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/groups?accountSwitchKey=$AccountSwitchKey"
    
    
    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.groups.items | where {$_.groupName -eq $group} 
    }
    catch {
        throw $_.Exception
    }
}