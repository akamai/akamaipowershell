function List-CustomBehaviors
{
    Param(
        [Parameter(Mandatory=$false)] [string] $EdgeRCFile = '~\.edgerc',
        [Parameter(Mandatory=$false)] [string] $Section = 'papi',
        [Parameter(Mandatory=$false)] [string] $AccountSwitchKey
    )

    $Path = "/papi/v1/custom-behaviors?accountSwitchKey=$AccountSwitchKey"

    try {
        $Result = Invoke-AkamaiRestMethod -Method GET -Path $Path -Body $Body -EdgeRCFile $EdgeRCFile -Section $Section
        return $Result.custombehaviors.items
    }
    catch {
        throw $_.Exception
    }
}