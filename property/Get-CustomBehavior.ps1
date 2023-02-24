function Get-CustomBehavior
{
    Param(
        [Parameter(Mandatory=$true)]  [string] $BehaviorID,
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile,
        [Parameter(Mandatory=$false)] [string] $Section,
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/custom-behaviors/$BehaviorID"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section -AccountSwitchKey $AccountSwitchKey
        return $Result.customBehaviors.items
    }
    catch {
        throw $_
    }
}
