function Set-GTMLoadData
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $Domain,
        [Parameter(Mandatory=$true)]  [string] $Resource,
        [Parameter(Mandatory=$true)]  [string] $DatacenterID,
        [Parameter(Mandatory=$true)]  [string] $Body,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/gtm-load-data/v1/$Domain/$Resource/$DatacenterID`?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result
    }
    catch {
        throw $_
    }
}
