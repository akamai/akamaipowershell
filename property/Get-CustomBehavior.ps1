function Get-CustomBehavior
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $BehaviorID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'default',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/custom-behaviors/$BehaviorID`?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.customBehaviors.items
    }
    catch {
        throw $_.Exception
    }
}